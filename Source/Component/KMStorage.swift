/**
 * @file	KMStorage.swift
 * @brief	Define KMStorage class
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

public class KMStorage: AMBComponentObject
{
	private static let NameItem		= "name"	// Name of storage
	private static let ArrayItem		= "array"
	private static let ArraysItem		= "arrays"
	private static let SetItem		= "set"
	private static let SetsItem		= "sets"
	private static let DictionaryItem	= "dictionary"
	private static let DictionariesItem	= "dictionaries"
	private static let TableItem		= "table"
	private static let TablesItem		= "tables"
	private static let SaveItem		= "save"

	private var mArrays:		Dictionary<String, CNStorageArray>	= [:]
	private var mSets:		Dictionary<String, CNStorageSet>	= [:]
	private var mDictionaries:	Dictionary<String, CNStorageDictionary>	= [:]
	private var mTables:		Dictionary<String, CNStorageTable>	= [:]

	public override func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		if let err = super.setup(reactObject: robj, console: cons) {
			return err
		}

		/* storage */
		let storagename: String
		if let name = robj.stringValue(forProperty: KMStorage.NameItem) {
			storagename = name
		} else {
			return NSError.fileError(message: "The 'name' property is required by KMStorage' component", location: #file)
		}

		guard let storage = robj.resource.loadStorage(identifier: storagename) else {
			return NSError.fileError(message: "No storage named: \(storagename)", location: #file)
		}

		/* Parse arrays */
		if let tbls = robj.dictionaryValue(forProperty: KMStorage.ArraysItem) {
			for (aname, apath) in tbls {
				if let name = aname as? String, let path = apath as? String {
					addArray(name: name, path: path, storage: storage, reactObject: robj)
				}
			}
		}

		/* array method */
		addScriptedProperty(object: robj, forProperty: KMStorage.ArrayItem)
		let arrayfunc: @convention(block) (_ name: JSValue) -> JSValue = {
			(_ name: JSValue) -> JSValue in
			if let namestr = name.toString() {
				if let arr = self.mArrays[namestr] {
					let arrobj = KLArray(array: arr, context: robj.context)
					return JSValue(object: arrobj, in: robj.context)
				} else {
					CNLog(logLevel: .error, message: "The array storage named \(namestr) is NOT found.")
				}
			} else {
				CNLog(logLevel: .error, message: "Invalid parameter for array method")
			}
			return JSValue(nullIn: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: arrayfunc, in: robj.context), forProperty: KMStorage.ArrayItem)

		/* Parse sets */
		if let tbls = robj.dictionaryValue(forProperty: KMStorage.SetsItem) {
			for (aname, apath) in tbls {
				if let name = aname as? String, let path = apath as? String {
					addSet(name: name, path: path, storage: storage, reactObject: robj)
				}
			}
		}

		/* set method */
		addScriptedProperty(object: robj, forProperty: KMStorage.SetItem)
		let setfunc: @convention(block) (_ name: JSValue) -> JSValue = {
			(_ name: JSValue) -> JSValue in
			if let namestr = name.toString() {
				if let set = self.mSets[namestr] {
					let setobj = KLSet(set: set, context: robj.context)
					return JSValue(object: setobj, in: robj.context)
				} else {
					CNLog(logLevel: .error, message: "The set storage named \(namestr) is NOT found.")
				}
			} else {
				CNLog(logLevel: .error, message: "Invalid parameter for set method")
			}
			return JSValue(nullIn: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: setfunc, in: robj.context), forProperty: KMStorage.SetItem)

		/* Parse dictionaries */
		if let tbls = robj.dictionaryValue(forProperty: KMStorage.DictionariesItem) {
			for (aname, apath) in tbls {
				if let name = aname as? String, let path = apath as? String {
					addDictionary(name: name, path: path, storage: storage, reactObject: robj)
				}
			}
		}

		/* dictionary method */
		addScriptedProperty(object: robj, forProperty: KMStorage.DictionaryItem)
		let dictfunc: @convention(block) (_ name: JSValue) -> JSValue = {
			(_ name: JSValue) -> JSValue in
			if let namestr = name.toString() {
				if let dict = self.mDictionaries[namestr] {
					let dictobj = KLDictionary(dictionary: dict, context: robj.context)
					return JSValue(object: dictobj, in: robj.context)
				} else {
					CNLog(logLevel: .error, message: "The dictionary storage named \(namestr) is NOT found.")
				}
			} else {
				CNLog(logLevel: .error, message: "Invalid parameter for dictionary method")
			}
			return JSValue(nullIn: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: dictfunc, in: robj.context), forProperty: KMStorage.DictionaryItem)

		/* Parse tables */
		if let tbls = robj.dictionaryValue(forProperty: KMStorage.TablesItem) {
			for (aname, apath) in tbls {
				if let name = aname as? String, let path = apath as? String {
					addTable(name: name, path: path, storage: storage, reactObject: robj)
				}
			}
		}

		/* table method */
		addScriptedProperty(object: robj, forProperty: KMStorage.TableItem)
		let tablefunc: @convention(block) (_ name: JSValue) -> JSValue = {
			(_ name: JSValue) -> JSValue in
			if let namestr = name.toString() {
				if let table = self.mTables[namestr] {
					let tableobj = KLTable(table: table, context: robj.context)
					return JSValue(object: tableobj, in: robj.context)
				} else {
					CNLog(logLevel: .error, message: "The table storage named \(namestr) is NOT found.")
				}
			} else {
				CNLog(logLevel: .error, message: "Invalid parameter for table method")
			}
			return JSValue(nullIn: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: tablefunc, in: robj.context), forProperty: KMStorage.TableItem)

		/* save method */
		addScriptedProperty(object: robj, forProperty: KMStorage.SaveItem)
		let savefunc: @convention(block) () -> JSValue = {
			() in return JSValue(bool: storage.save(), in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: savefunc, in: robj.context), forProperty: KMStorage.SaveItem)

		return nil
	}

	private func addArray(name nm: String, path pstr: String, storage strg: CNStorage, reactObject robj: AMBReactObject) {
		switch CNValuePath.pathExpression(string: pstr) {
		case .success(let path):
			let arr     = CNStorageArray(path: path, storage: strg)
			mArrays[nm] = arr
		case .failure(let err):
			CNLog(logLevel: .error, message: "Failed to allocate path for array: path=\(pstr), err=\(err.toString())", atFunction: #function, inFile: #file)
		}
	}

	private func addSet(name nm: String, path pstr: String, storage strg: CNStorage, reactObject robj: AMBReactObject) {
		switch CNValuePath.pathExpression(string: pstr) {
		case .success(let path):
			let sets    = CNStorageSet(path: path, storage: strg)
			mSets[nm]   = sets
		case .failure(let err):
			CNLog(logLevel: .error, message: "Failed to allocate path for set: path=\(pstr), err=\(err.toString())", atFunction: #function, inFile: #file)
		}
	}

	private func addDictionary(name nm: String, path pstr: String, storage strg: CNStorage, reactObject robj: AMBReactObject) {
		switch CNValuePath.pathExpression(string: pstr) {
		case .success(let path):
			let dict            = CNStorageDictionary(path: path, storage: strg)
			mDictionaries[nm]   = dict
		case .failure(let err):
			CNLog(logLevel: .error, message: "Failed to allocate path for set: path=\(pstr), err=\(err.toString())", atFunction: #function, inFile: #file)
		}
	}

	private func addTable(name nm: String, path pstr: String, storage strg: CNStorage, reactObject robj: AMBReactObject) {
		switch CNValuePath.pathExpression(string: pstr) {
		case .success(let path):
			let table    = CNStorageTable(path: path, storage: strg)
			mTables[nm]  = table
		case .failure(let err):
			CNLog(logLevel: .error, message: "Failed to allocate path for table: path=\(pstr), err=\(err.toString())", atFunction: #function, inFile: #file)
		}
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(storage: self)
	}
}

