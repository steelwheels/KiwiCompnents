/**
 * @file	KMDictionary.swift
 * @brief	Define KMDictionary class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
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

public class KMDictionaryData: AMBComponentObject
{
	private static let StorageItem		= "storage"
	private static let PathItem		= "path"
	private static let CountItem		= "count"
	private static let KeysItem		= "keys"
	private static let ValueItem		= "value"
	private static let ValuesItem		= "values"
	private static let SetItem		= "set"
	private static let DictionaryItem	= "dictionary"
	private static let UpdateItem		= "update"
	private static let SaveItem		= "save"

	private var mDictionary: 	CNStorageDictionary? = nil
	private var mEventCallbackId:	Int?	= nil
	private var mUpdateCount:	Int 	= 0

	deinit {
		if let dict = mDictionary, let eid = mEventCallbackId {
			dict.removeEventFunction(eventFuncId: eid)
		}
	}

	public override func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		if let err = super.setup(reactObject: robj, console: cons) {
			return err
		}

		/* storage */
		let storagename: String
		if let name = robj.stringValue(forProperty: KMDictionaryData.StorageItem) {
			storagename = name
		} else {
			return NSError.fileError(message: "The 'name' property is required by KMDictionary' component")
		}

		/* path */
		let pathname: String
		if let name = robj.stringValue(forProperty: KMDictionaryData.PathItem) {
			pathname = name
		} else {
			return NSError.fileError(message: "The 'path' property is required by KMDictionary' component")
		}

		/* Load storage dictionary */
		let dict: CNStorageDictionary
		let res = robj.resource
		if let storage = res.loadStorage(identifier: storagename) {
			switch CNValuePath.pathExpression(string: pathname) {
			case .success(let path):
				dict = CNStorageDictionary(path: path, storage: storage)
				mDictionary = dict
			case .failure(let err):
				return err
			}
		} else {
			return NSError.fileError(message: "Failed to load storage named: \(storagename)")
		}

		/* count */
		addScriptedProperty(object: robj, forProperty: KMDictionaryData.CountItem)
		robj.setNumberValue(value: NSNumber(integerLiteral: dict.count), forProperty: KMDictionaryData.CountItem)

		/* update */
		addScriptedProperty(object: robj, forProperty: KMDictionaryData.UpdateItem)
		robj.setNumberValue(value: NSNumber(integerLiteral: mUpdateCount), forProperty: KMDictionaryData.UpdateItem)
		mUpdateCount += 1

		/* keys */
		addScriptedProperty(object: robj, forProperty: KMDictionaryData.KeysItem)
		let keys = dict.keys.map({ (_ key: String) -> CNValue in return .stringValue(key) })
		robj.setArrayValue(value: keys, forProperty: KMDictionaryData.KeysItem)

		/* values */
		addScriptedProperty(object: robj, forProperty: KMDictionaryData.ValuesItem)
		robj.setArrayValue(value: dict.values, forProperty: KMDictionaryData.ValuesItem)

		/* value method */
		addScriptedProperty(object: robj, forProperty: KMDictionaryData.ValueItem)
		let valfunc: @convention(block) (_ key: JSValue) -> JSValue = {
			(_ keyval: JSValue) -> JSValue in
			if let keystr = keyval.toString() {
				let resval = self.getValue(forKey: keystr)
				return resval.toJSValue(context: robj.context)
			} else {
				CNLog(logLevel: .error, message: "Invalid parameter for dictionary method")
			}
			return JSValue(nullIn: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: valfunc, in: robj.context), forProperty: KMDictionaryData.ValueItem)

		/* set method */
		addScriptedProperty(object: robj, forProperty: KMDictionaryData.SetItem)
		let setfunc: @convention(block) (_ srvval: JSValue, _ keyval: JSValue) -> Void = {
			(_ srcval: JSValue, _ keyval: JSValue) -> Void in
			if let keystr = keyval.toString() {
				let src = srcval.toNativeValue()
				self.setValue(source: src, forKey: keystr)
			} else {
				CNLog(logLevel: .error, message: "Invalid parameter for dictionary method")
			}
		}
		robj.setImmediateValue(value: JSValue(object: setfunc, in: robj.context), forProperty: KMDictionaryData.SetItem)

		/* save method */
		addScriptedProperty(object: robj, forProperty: KMDictionaryData.SaveItem)
		let savefunc: @convention(block) () -> Void = {
			() -> Void in
			if let dict = self.mDictionary {
				if dict.save() {
					/* succeeded */
				} else {
					CNLog(logLevel: .error, message: "Failed to save value", atFunction: #function, inFile: #file)
				}
			} else {
				CNLog(logLevel: .error, message: "No dictionary body", atFunction: #function, inFile: #file)
			}
		}
		robj.setImmediateValue(value: JSValue(object: savefunc, in: robj.context), forProperty: KMDictionaryData.SaveItem)


		/* dictionary */
		addScriptedProperty(object: robj, forProperty: KMDictionaryData.DictionaryItem)
		updateDictionaryProperty()

		/* callback */
		mEventCallbackId = dict.allocateEventFunction(eventFunc: {
			() -> Void in self.updateEvent()
		})
		return nil // setup done without errors
	}

	private func getValue(forKey key: String) -> CNValue {
		if let dict = mDictionary {
			if let res = dict.value(forKey: key) {
				return res
			}
		}
		return .nullValue
	}

	private func setValue(source src: CNValue, forKey key: String) {
		if let dict = mDictionary {
			if !dict.set(value: src, forKey: key) {
				CNLog(logLevel: .error, message: "Failed to set value", atFunction: #function, inFile: #file)
			}
		} else {
			CNLog(logLevel: .error, message: "No storage", atFunction: #function, inFile: #file)
		}
	}

	private func updateEvent() {
		let robj = self.reactObject
		if let dict = mDictionary {
			/* keys */
			let keys = dict.keys.map({ (_ key: String) -> CNValue in return .stringValue(key) })
			robj.setArrayValue(value: keys, forProperty: KMDictionaryData.KeysItem)

			/* values */
			robj.setArrayValue(value: dict.values, forProperty: KMDictionaryData.ValuesItem)

			/* count */
			robj.setNumberValue(value: NSNumber(integerLiteral: dict.count), forProperty: KMDictionaryData.CountItem)

			/* dictionary */
			updateDictionaryProperty()

			/* update count */
			addScriptedProperty(object: robj, forProperty: KMDictionaryData.UpdateItem)
			robj.setNumberValue(value: NSNumber(integerLiteral: mUpdateCount), forProperty: KMDictionaryData.UpdateItem)
			mUpdateCount += 1
		}
	}

	private func updateDictionaryProperty() {
		let robj = self.reactObject

		let dictval: JSValue
		if let dict = mDictionary {
			let dictobj = KLDictionary(dictionary: dict, context: robj.context)
			if let val = KLDictionary.allocate(dictionary: dictobj) {
				dictval = val
			} else {
				CNLog(logLevel: .error, message: "Failed to allocate dictionary", atFunction: #function, inFile: #file)
				dictval = JSValue(nullIn: robj.context)
			}
		} else {
			CNLog(logLevel: .error, message: "No source dictionary", atFunction: #function, inFile: #file)
			dictval = JSValue(nullIn: robj.context)
		}
		robj.setImmediateValue(value: dictval, forProperty: KMDictionaryData.DictionaryItem)
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(dictionaryData: self)
	}
}

