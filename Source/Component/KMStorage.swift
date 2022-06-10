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
	private static let PathItem		= "path"
	private static let TableItem		= "table"
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

		/* path */
		let pathstr: String
		if let path = robj.stringValue(forProperty: KMStorage.PathItem) {
			pathstr = path
		} else {
			return NSError.fileError(message: "The 'path' property is required by 'ValueStorage' component", location: #file)
		}

		/* Allocate path object */
		let vpath: CNValuePath
		switch CNValuePath.pathExpression(string: pathstr) {
		case .success(let p):
			vpath = p
		case .failure(let err):
			return err
		}

		/* Allocate table */
		addScriptedProperty(object: robj, forProperty: KMStorage.TableItem)
		let table    = CNValueTable(path: vpath, valueStorage: storage)
		let tableobj = KLValueTable(table: table, context: robj.context)
		robj.setImmediateValue(value: JSValue(object: tableobj, in: robj.context), forProperty: KMStorage.TableItem)

		/* save method */
		addScriptedProperty(object: robj, forProperty: KMStorage.SaveItem)
		let savefunc: @convention(block) () -> JSValue = {
			() in return JSValue(bool: storage.save(), in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: savefunc, in: robj.context), forProperty: KMStorage.SaveItem)

		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(storage: self)
	}
}

