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
import JavaScriptCore
import CoconutDatabase
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMContactDatabase: AMBComponentObject
{
	private static let ValueItem		= "value"
	private static let SetValueItem		= "setValue"


	public override func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		if let err = super.setup(reactObject: robj, console: cons) {
			return err
		}

		/* Start authentication and load data */
		let db = CNContactDatabase.shared
		db.authorize(callback: {
			(_ granted: Bool) -> Void in
			if granted {
				switch db.load(URL: nil){
				case .ok:
					CNLog(logLevel: .detail, message: "Contacts data has been loaded", atFunction: #function, inFile: #file)
				case .error(let err):
					CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
				@unknown default:
					CNLog(logLevel: .error, message: "Unknown condition", atFunction: #function, inFile: #file)
				}
			} else {
				CNLog(logLevel: .error, message: "Failed to authenticate", atFunction: #function, inFile: #file)
			}
		})

		/* add value method: value(index:number, propert:string) */
		let valuefunc: @convention(block) (_ idx: JSValue, _ prop: JSValue) -> JSValue = {
			(_ idx: JSValue, _ prop: JSValue) -> JSValue in
			return self.value(index: idx, property: prop, reactObject: robj)
		}
		robj.setImmediateValue(value: JSValue(object: valuefunc, in: robj.context), forProperty: KMContactDatabase.ValueItem)
		robj.addScriptedPropertyName(name: KMContactDatabase.ValueItem)

		/* add value method: setValue(index:number, propert:string, value: any) */
		let setvalfunc: @convention(block) (_ idx: JSValue, _ prop: JSValue, _ val: JSValue) -> JSValue = {
			(_ idx: JSValue, _ prop: JSValue, _ val: JSValue) -> JSValue in
			return self.setValue(index: idx, property: prop, value: val, reactObject: robj)
		}
		robj.setImmediateValue(value: JSValue(object: setvalfunc, in: robj.context), forProperty: KMContactDatabase.SetValueItem)
		robj.addScriptedPropertyName(name: KMContactDatabase.SetValueItem)

		return nil
	}

	private func value(index idx: JSValue, property prop: JSValue, reactObject robj: AMBReactObject) -> JSValue {
		var result: CNNativeValue = .nullValue
		if idx.isNumber && prop.isString {
			let db = CNContactDatabase.shared
			if let rec = db.record(at: Int(idx.toInt32())) {
				if let val = rec.value(ofField: prop.toString()) {
					result = val
				} else {
					CNLog(logLevel: .error, message: "Invalid property name: \(String(describing: prop.toString()))", atFunction: #function, inFile: #file)
				}
			} else {
				CNLog(logLevel: .error, message: "Invalid row index: \(idx.toInt32())", atFunction: #function, inFile: #file)
			}
		} else {
			CNLog(logLevel: .error, message: "Invalid parameter", atFunction: #function, inFile: #file)
		}
		return result.toJSValue(context: robj.context)
	}

	private func setValue(index idx: JSValue, property prop: JSValue, value val: JSValue, reactObject robj: AMBReactObject) -> JSValue {
		var result = false
		if idx.isNumber && prop.isString {
			let db = CNContactDatabase.shared
			if let rec = db.record(at: Int(idx.toInt32())) {
				if rec.setValue(value: val.toNativeValue(), forField: prop.toString()) {
					result = true
				} else {
					let valtxt = val.toText().toStrings().joined(separator: "\n")
					CNLog(logLevel: .error, message: "Invalid property name or data: name=\(String(describing: prop.toString())), value=\(valtxt)", atFunction: #function, inFile: #file)
				}
			} else {
				CNLog(logLevel: .error, message: "Invalid row index: \(idx.toInt32())", atFunction: #function, inFile: #file)
			}
		}
		return JSValue(bool: result, in: robj.context)
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(contactDatabase: self)
	}
}


