/**
 * @file	KMTextEdit.swift
 * @brief	Define KMTextEdit class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import KiwiControls
import KiwiEngine
import CoconutData
import Foundation
import JavaScriptCore
#if os(iOS)
import UIKit
#endif

public class KMTextEdit: KCTextEdit, AMBComponent
{
	public static let TextItem		= "text"
	public static let NumberItem		= "number"
	public static let IsBezeledItem		= "isBezeled"
	public static let FontSizeItem		= "fontSize"
	public static let EditedItem		= "edited"
	public static let DecimalPlacesItem	= "decimalPlaces"

	private var mReactObject:	AMBReactObject?
	private var mChildComponents:	Array<AMBComponent>

	public var reactObject: AMBReactObject	{ get {
		if let robj = mReactObject {
			return robj
		} else {
			fatalError("No react object")
		}
	}}

	public var children: Array<AMBComponent> { get { return [] }}

	public init(){
		mReactObject		= nil
		mChildComponents	= []
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#endif
		super.init(frame: frame)
	}

	@objc required dynamic init?(coder: NSCoder) {
		mReactObject		= nil
		mChildComponents	= []
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj

		/* text */
		addScriptedProperty(object: robj, forProperty: KMTextEdit.TextItem)
		if let val = robj.stringValue(forProperty: KMTextEdit.TextItem) {
			super.text = val
		} else {
			robj.setStringValue(value: self.text, forProperty: KMTextEdit.TextItem)
		}
		robj.addObserver(forProperty: KMTextEdit.TextItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.stringValue(forProperty: KMTextEdit.TextItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					self.text = val
				})
			}
		})

		/* number */
		addScriptedProperty(object: robj, forProperty: KMTextEdit.NumberItem)
		if let val = robj.numberValue(forProperty: KMTextEdit.NumberItem) {
			super.number = val
		} else {
			/* Initialization is NOT executed because self.text will be initialized */
		}
		robj.addObserver(forProperty: KMTextEdit.NumberItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.numberValue(forProperty: KMTextEdit.NumberItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					self.number = val
				})
			}
		})

		/* isBezeled */
		addScriptedProperty(object: robj, forProperty: KMTextEdit.IsBezeledItem)
		if let val = robj.boolValue(forProperty: KMTextEdit.IsBezeledItem) {
			super.isBezeled = val
		} else {
			robj.setBoolValue(value: super.isBezeled, forProperty: KMTextEdit.IsBezeledItem)
		}
		robj.addObserver(forProperty: KMTextEdit.IsBezeledItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.boolValue(forProperty: KMTextEdit.IsBezeledItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					super.isBezeled = val
				})
			}
		})

		/* fontSize */
		addScriptedProperty(object: robj, forProperty: KMTextEdit.FontSizeItem)
		if let val = robj.int32Value(forProperty: KMTextEdit.FontSizeItem) {
			super.font = CNFont.systemFont(ofSize: CGFloat(val))
		} else {
			let val = Int32(CNFont.systemFontSize)
			robj.setInt32Value(value: val, forProperty: KMTextEdit.FontSizeItem)
		}
		robj.addObserver(forProperty: KMTextEdit.FontSizeItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMTextEdit.FontSizeItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					super.font = CNFont.systemFont(ofSize: CGFloat(val))
				})
			}
		})

		/* decimalPlaces */
		addScriptedProperty(object: robj, forProperty: KMTextEdit.DecimalPlacesItem)
		if let val = robj.int32Value(forProperty: KMTextEdit.DecimalPlacesItem) {
			super.decimalPlaces = Int(val)
		} else {
			robj.setInt32Value(value: Int32(self.decimalPlaces), forProperty: KMTextEdit.DecimalPlacesItem)
		}
		robj.addObserver(forProperty: KMTextEdit.DecimalPlacesItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMTextEdit.DecimalPlacesItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					self.decimalPlaces = Int(val)
				})
			}
		})

		/* Add callbacks */
		self.callbackFunction = {
			(_ newval: String) -> Void in
			if let evtval = robj.immediateValue(forProperty: KMTextEdit.EditedItem) {
				if let valobj = JSValue(object: newval, in: robj.context) {
					CNExecuteInUserThread(level: .event, execute: {
						evtval.call(withArguments: [robj, valobj])	// insert self
					})
				} else {
					CNLog(logLevel: .error, message: "Failed to allocate parameter", atFunction: #function, inFile: #file)
				}
			}
		}
		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(textEdit: self)
	}

	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Unsupported method: addChild")
	}
}

