/**
 * @file	KMPopupMenu.swift
 * @brief	Define KMPopupMenu class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import KiwiShell
import KiwiEngine
import KiwiControls
import Amber
import CoconutData
import JavaScriptCore
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMPopupMenu: KCPopupMenu, AMBComponent
{
	public typealias MenuItem = KCPopupMenu.MenuItem

	private static let AddItemItem		= "addItem"
	private static let ItemsItem		= "items"
	private static let SelectedItem		= "selected"
	private static let ValueItem		= "value"

	private var mReactObject:	AMBReactObject?

	public var reactObject: AMBReactObject {
		get {
			if let robj = mReactObject {
				return robj
			} else {
				fatalError("No react object")
			}
		}
	}

	public init() {
		mReactObject	= nil
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 50, height: 50)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
		#endif
		super.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		mReactObject	= nil
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj

		/* items */
		addScriptedProperty(object: robj, forProperty: KMPopupMenu.ItemsItem)
		if let arr = robj.arrayValue(forProperty: KMPopupMenu.ItemsItem) {
			let menuitems = arrayToMenuItems(array: arr)
			super.removeAllItems()
			super.addItems(menuitems)

		} else {
			let empty: Array<CNValue> = []
			robj.setArrayValue(value: empty, forProperty: KMPopupMenu.ItemsItem)
		}
		robj.addObserver(forProperty: KMPopupMenu.ItemsItem, callback: {
			(_ param: Any) -> Void in
			if let arr = robj.arrayValue(forProperty: KMPopupMenu.ItemsItem) {
				let menuitems = self.arrayToMenuItems(array: arr)
				CNExecuteInMainThread(doSync: false, execute: {
					super.removeAllItems()
					super.addItems(menuitems)
				})
			}
		})

		/* value (readonly) */
		addScriptedProperty(object: robj, forProperty: KMPopupMenu.ValueItem)
		if let sval = super.selectedValue() {
			robj.setImmediateValue(value: sval.toJSValue(context: robj.context), forProperty: KMPopupMenu.ValueItem)
		} else {
			robj.setImmediateValue(value: JSValue(nullIn: robj.context), forProperty: KMPopupMenu.ValueItem)
		}

		/* addItem(title, value) */
		addScriptedProperty(object: robj, forProperty: KMPopupMenu.AddItemItem)
		let fnamefunc: @convention(block) (_ title: JSValue, _ value: JSValue) -> JSValue = {
			(_ title: JSValue, _ value: JSValue) -> JSValue in
			var result = false
			if title.isString {
				if let str = title.toString() {
					let nval = value.toNativeValue()
					CNExecuteInMainThread(doSync: false, execute: {
						let item = KCPopupMenu.MenuItem(title: str, value: nval)
						super.addItem(item)
					})
					result = true
				}
			}
			return JSValue(bool: result, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: fnamefunc, in: robj.context), forProperty: KMPopupMenu.AddItemItem)

		/* Callback */
		super.callbackFunction = {
			(_ val: CNValue) -> Void in
			/* set value property */
			let valobj = val.toJSValue(context: robj.context)
			robj.setImmediateValue(value: valobj, forProperty: KMPopupMenu.ValueItem)

			if let evtval = robj.immediateValue(forProperty: KMPopupMenu.SelectedItem) {
				CNExecuteInUserThread(level: .event, execute: {
					evtval.call(withArguments: [robj, valobj])	// insert self, value
				})
			}
		}

		return nil
	}

	private func arrayToMenuItems(array arr: Array<Any>) -> Array<MenuItem> {
		var result: Array<MenuItem> = []
		for elm in arr {
			if let dict = elm as? Dictionary<String, Any> {
				if let item = dictionaryToMenuItem(dictionary: dict) {
					result.append(item)
				}
			} else {
				CNLog(logLevel: .error, message: "Invalid data for popup menu item")
			}
		}
		return result
	}

	private func dictionaryToMenuItem(dictionary dict: Dictionary<String, Any>) -> MenuItem? {
		guard let title = dict["title"] as? String else {
			CNLog(logLevel: .error, message: "No (or unexpected) \"title\" value for popup menu item")
			return nil
		}
		guard let elm = dict["value"] else {
			CNLog(logLevel: .error, message: "No \"value\" value for popup menu item")
			return nil
		}
		guard let val = CNValue.anyToValue(object: elm) else {
			CNLog(logLevel: .error, message: "Unexpected value of \"value\" field for popup menu item")
			return nil
		}
		return MenuItem(title: title, value: val)
	}

	public var children: Array<AMBComponent> { get { return [] }}

	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Can not add child components to PopupMenu component")
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(popupMenu: self)
	}
}

