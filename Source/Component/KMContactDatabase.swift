/**
 * @file	KMContactDatabase.swift
 * @brief	Define KMContactDatabase class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation
import KiwiControls
import Amber
import KiwiEngine
import KiwiLibrary
import JavaScriptCore
import CoconutDatabase
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMContactDatabase: AMBComponentObject
{
	private static let RecordItem		= "record"
	private static let CountItem		= "count"
	private static let IndexItem		= "index"

	private var mCurrentIndex: Int = 0

	public override func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		if let err = super.setup(reactObject: robj, console: cons) {
			return err
		}

		/* Start authentication and load data */
		let db = CNContactDatabase.shared
		db.authorize(callback: {
			(_ granted: Bool) -> Void in
			if granted {
				switch db.load(fromURL: nil){
				case .ok:
					CNLog(logLevel: .detail, message: "Contacts data has been loaded", atFunction: #function, inFile: #file)
					self.setIndex(index: self.mCurrentIndex, reactObject: robj)
				case .error(let err):
					CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
				@unknown default:
					CNLog(logLevel: .error, message: "Unknown condition", atFunction: #function, inFile: #file)
				}
			} else {
				CNLog(logLevel: .error, message: "Failed to authenticate", atFunction: #function, inFile: #file)
			}
		})

		/* Index */
		addScriptedProperty(object: robj, forProperty: KMContactDatabase.IndexItem)
		if let val = robj.int32Value(forProperty: KMContactDatabase.IndexItem) {
			mCurrentIndex = Int(val)
		} else {
			robj.setInt32Value(value: Int32(mCurrentIndex), forProperty: KMContactDatabase.IndexItem)
		}
		robj.addObserver(forProperty: KMContactDatabase.IndexItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMContactDatabase.IndexItem) {
				self.setIndex(index: Int(val), reactObject: robj)
			} else {
				let ival = robj.immediateValue(forProperty: KMContactDatabase.IndexItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMContactDatabase.IndexItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* record */
		addScriptedProperty(object: robj, forProperty: KMContactDatabase.RecordItem)
		robj.setImmediateValue(value: JSValue(nullIn: robj.context), forProperty: KMContactDatabase.RecordItem)

		/* count */
		addScriptedProperty(object: robj, forProperty: KMContactDatabase.CountItem)
		robj.setInt32Value(value: Int32(db.recordCount), forProperty: KMContactDatabase.CountItem)

		return nil
	}

	private func setIndex(index idx: Int, reactObject robj: AMBReactObject) {
		/* Update index */
		mCurrentIndex = idx

		/* Update record */
		let newobj: JSValue
		let db = CNContactDatabase.shared
		if let rec = db.record(at: idx) {
			let newrec = KLRecord(record: rec, context: robj.context)
			newobj = KLRecord.allocate(record: newrec, atFunction: #function, inFile: #file)
		} else {
			newobj = JSValue(nullIn: robj.context)
		}
		robj.setImmediateValue(value: newobj, forProperty: KMContactDatabase.RecordItem)
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(contactDatabase: self)
	}
}


