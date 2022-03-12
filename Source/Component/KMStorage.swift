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
		guard let pathelms = CNValuePath.pathExpression(string: pathstr) else {
			return NSError.fileError(message: "Invalid 'path' property for 'ValueStorage' component", location: #file)
		}

		/* Allocate table */
		addScriptedProperty(object: robj, forProperty: KMStorage.TableItem)
		let table    = CNValueTable(path: CNValuePath(elements: pathelms), valueStorage: storage)
		let tableobj = KLValueTable(table: table, context: robj.context)
		robj.setImmediateValue(value: JSValue(object: tableobj, in: robj.context), forProperty: KMStorage.TableItem)

		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(storage: self)
	}
}

