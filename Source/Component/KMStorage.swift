/**
 * @file	KMValueStorage.swift
 * @brief	Define KMValueStorage class
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
	private static let TablesItem		= "tables"
	private static let SaveItem		= "save"

	public override func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		if let err = super.setup(reactObject: robj, console: cons) {
			return err
		}

		/* storage */
		let storagename: String
		if let name = robj.stringValue(forProperty: KMStorage.NameItem) {
			storagename = name
		} else {
			return NSError.fileError(message: "The 'name' property is required by 'ValueStorage' component", location: #file)
		}

		guard let storage = robj.resource.loadStorage(identifier: storagename) else {
			return NSError.fileError(message: "No storage named: \(storagename)", location: #file)
		}

		/* Parse tables */
		if let tbls = robj.dictionaryValue(forProperty: KMStorage.TablesItem) {
			for (aname, apath) in tbls {
				if let name = aname as? String, let path = apath as? String {
					addTable(name: name, path: path, storage: storage, reactObject: robj)
				}
			}
		}

		/* save method */
		addScriptedProperty(object: robj, forProperty: KMStorage.SaveItem)
		let savefunc: @convention(block) () -> JSValue = {
			() in return JSValue(bool: storage.save(), in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: savefunc, in: robj.context), forProperty: KMStorage.SaveItem)

		return nil
	}

	private func addTable(name nm: String, path pstr: String, storage strg: CNValueStorage, reactObject robj: AMBReactObject) {
		addScriptedProperty(object: robj, forProperty: nm)
		switch CNValuePath.pathExpression(string: pstr) {
		case .success(let path):
			let table    = CNValueTable(path: path, valueStorage: strg)
			let tableobj = KLValueTable(table: table, context: robj.context)
			robj.setImmediateValue(value: JSValue(object: tableobj, in: robj.context), forProperty: nm)
		case .failure(let err):
			CNLog(logLevel: .error, message: "Failed to allocate path for table: path=\(pstr), err=\(err.toString())", atFunction: #function, inFile: #file)
		}
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(storage: self)
	}
}

