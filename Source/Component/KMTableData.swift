/**
 * @file	KMTableData.swift
 * @brief	Define KMTableData class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import Foundation
import KiwiControls
import Amber
import KiwiEngine
import KiwiLibrary
import JavaScriptCore
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMTableData: AMBComponentObject
{
	private static let AppendItem		= "append"
	private static let StorageItem		= "storage"
	private static let PathItem		= "path"
	private static let FieldNameItem	= "fieldName"
	private static let FieldNamesItem	= "fieldNames"
	private static let NewRecordItem	= "newRecord"
	private static let RecordItem		= "record"
	private static let RecordCountItem	= "recordCount"
	private static let TableItem		= "table"

	private var mTable: 	CNStorageTable? = nil
	private var mEventCallbackId:	Int?	= nil

	deinit {
		if let table = mTable, let eid = mEventCallbackId {
			table.removeEventFunction(eventFuncId: eid)
		}
	}

	public override func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		if let err = super.setup(reactObject: robj, console: cons) {
			return err
		}

		/* storage */
		let storagename: String
		if let name = robj.stringValue(forProperty: KMTableData.StorageItem) {
			storagename = name
		} else {
			return NSError.fileError(message: "The '\(KMTableData.StorageItem)' property is required by Table component")
		}

		/* path */
		let pathname: String
		if let name = robj.stringValue(forProperty: KMTableData.PathItem) {
			pathname = name
		} else {
			return NSError.fileError(message: "The '\(KMTableData.PathItem)' property is required by Table component")
		}

		/* Load storage dictionary */
		let table: CNStorageTable
		let res = robj.resource
		if let storage = res.loadStorage(identifier: storagename) {
			switch CNValuePath.pathExpression(string: pathname) {
			case .success(let path):
				table = CNStorageTable(path: path, storage: storage)
				mTable = table
			case .failure(let err):
				return err
			}
		} else {
			return NSError.fileError(message: "Failed to load storage named: \(storagename)")
		}

		/* recordCount */
		addScriptedProperty(object: robj, forProperty: KMTableData.RecordCountItem)
		robj.setNumberValue(value: NSNumber(integerLiteral: table.recordCount), forProperty: KMTableData.RecordCountItem)

		/* fieldNames */
		addScriptedProperty(object: robj, forProperty: KMTableData.FieldNamesItem)
		let fnames = table.fieldNames.map({ (_ key: String) -> CNValue in return .stringValue(key) })
		robj.setArrayValue(value: fnames, forProperty: KMTableData.FieldNamesItem)

		/* fieldName() */
		addScriptedProperty(object: robj, forProperty: KMTableData.FieldNameItem)
		let fnamefunc: @convention(block) (_ idxval: JSValue) -> JSValue = {
			(_ idxval: JSValue) -> JSValue in
			if idxval.isNumber {
				if let fname = table.fieldName(at: Int(idxval.toInt32())) {
					return JSValue(object: fname, in: robj.context)
				} else {
					CNLog(logLevel: .error, message: "Invalid index range: \(idxval.toInt32())")
				}
			} else {
				CNLog(logLevel: .error, message: "Invalid parameter for \(KMTableData.FieldNameItem) method")
			}
			return JSValue(nullIn: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: fnamefunc, in: robj.context), forProperty: KMTableData.FieldNameItem)

		/* newRecord() */
		addScriptedProperty(object: robj, forProperty: KMTableData.NewRecordItem)
		let newrecfunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			let nrec   = table.newRecord()
			let recobj = KLRecord(record: nrec, context: robj.context)
			if let val = KLRecord.allocate(record: recobj) {
				return val
			} else {
				return JSValue(nullIn: robj.context)
			}
		}
		robj.setImmediateValue(value: JSValue(object: newrecfunc, in: robj.context), forProperty: KMTableData.NewRecordItem)

		/* record(index) */
		addScriptedProperty(object: robj, forProperty: KMTableData.RecordItem)
		let recfunc: @convention(block) (_ idxval: JSValue) -> JSValue = {
			(_ idxval: JSValue) -> JSValue in
			if idxval.isNumber {
				if let rec = table.record(at: Int(idxval.toInt32())) {
					let recobj = KLRecord(record: rec, context: robj.context)
					if let val = KLRecord.allocate(record: recobj) {
						return val
					} else {
						CNLog(logLevel: .error, message: "Failed to allocate record")
					}
				} else {
					CNLog(logLevel: .error, message: "Unexpected index range: \(idxval.toInt32())")
				}
			}
			return JSValue(nullIn: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: recfunc, in: robj.context), forProperty: KMTableData.RecordItem)

		/* append(record) */
		addScriptedProperty(object: robj, forProperty: KMTableData.AppendItem)
		let appendfunc: @convention(block) (_ recval: JSValue) -> JSValue = {
			(_ recval: JSValue) -> JSValue in
			if recval.isObject {
				if let rec = recval.toObject() as? KLRecord {
					table.append(record: rec.core())
				} else {
					CNLog(logLevel: .error, message: "Failed to convert to record")
				}
			} else {
				CNLog(logLevel: .error, message: "Not record parameter: \(recval)")
			}
			return JSValue(nullIn: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: appendfunc, in: robj.context), forProperty: KMTableData.AppendItem)

		/* table() */
		addScriptedProperty(object: robj, forProperty: KMTableData.TableItem)
		let tabfunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			if let table = self.mTable {
				let tabobj = KLTable(table: table, context: robj.context)
				return JSValue(object: tabobj, in: robj.context)
			} else {
				return JSValue(nullIn: robj.context)
			}
		}
		robj.setImmediateValue(value: JSValue(object: tabfunc, in: robj.context), forProperty: KMTableData.TableItem)

		/* callback for update event */
		mEventCallbackId = table.allocateEventFunction(eventFunc: {
			() -> Void in self.updateData()
		})
		return nil // no error
	}

	private func updateData() {
		if let table = mTable {
			let robj = super.reactObject

			/* fieldNames */
			let fnames = table.fieldNames.map({ (_ key: String) -> CNValue in return .stringValue(key) })
			robj.setArrayValue(value: fnames, forProperty: KMTableData.FieldNamesItem)

			/* recordCount */
			robj.setNumberValue(value: NSNumber(integerLiteral: table.recordCount), forProperty: KMTableData.RecordCountItem)
		}
	}
}

