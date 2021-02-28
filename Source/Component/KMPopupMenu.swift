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
	static let ItemsItem		= "items"
	static let IndexItem		= "index"
	static let SelectedItem		= "selected"

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
		if let val = robj.arrayValue(forProperty: KMPopupMenu.ItemsItem) {
			if let arr = val as? Array<String> {
				super.removeAllItems()
				super.addItems(withTitles: arr)
			} else {
				cons.error(string: "Invalid value for popup menu items [0]: \(val)\n")
			}
		} else {
			let empty: Array<String> = []
			robj.setArrayValue(value: empty, forProperty: KMPopupMenu.ItemsItem)
		}
		robj.addObserver(forProperty: KMPopupMenu.ItemsItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.arrayValue(forProperty: KMPopupMenu.ItemsItem) {
				if let arr = val as? Array<String> {
					CNExecuteInMainThread(doSync: false, execute: {
						super.removeAllItems()
						super.addItems(withTitles: arr)
					})
				} else {
					cons.error(string: "Invalid value for popup menu items [1]: \(val)\n")
				}
			}
		})

		/* Index */
		robj.setInt32Value(value: Int32(self.indexOfSelectedItem), forProperty: KMPopupMenu.IndexItem)
		robj.addScriptedPropertyName(name: KMPopupMenu.IndexItem)

		/* Callback */
		super.callbackFunction = {
			(_ index: Int, _ title: String?) -> Void in
			if let evtval = robj.immediateValue(forProperty: KMPopupMenu.SelectedItem),
			   let idxval = JSValue(int32: Int32(index), in: robj.context) {
				CNExecuteInMainThread(doSync: false, execute: {
					evtval.call(withArguments: [robj, idxval])	// insert self, index
				})
			}
		}

		return nil
	}

	public var children: Array<AMBComponent> { get { return [] }}

	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Can not add child components to PopupMenu component")
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(popupMenu: self)
	}
}

