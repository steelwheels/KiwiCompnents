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
	private static let TextItem		= "text"
	private static let NumberItem		= "number"
	private static let IsBoldItem		= "isBold"
	private static let IsEditableItem	= "isEditable"
	private static let FontSizeItem		= "fontSize"
	private static let EditedItem		= "edited"
	private static let DecimalPlacesItem	= "decimalPlaces"

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

		/* isBold */
		addScriptedProperty(object: robj, forProperty: KMTextEdit.IsBoldItem)
		if let val = robj.boolValue(forProperty: KMTextEdit.IsBoldItem) {
			super.isBold = val
		} else {
			let val = Bool(super.isBold)
			robj.setBoolValue(value: val, forProperty: KMTextEdit.IsBoldItem)
		}
		robj.addObserver(forProperty: KMTextEdit.IsBoldItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.boolValue(forProperty: KMTextEdit.IsBoldItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					super.isBold = val
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMTextEdit.IsBoldItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMTextEdit.IsBoldItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* isEditable */
		addScriptedProperty(object: robj, forProperty: KMTextEdit.IsEditableItem)
		if let val = robj.boolValue(forProperty: KMTextEdit.IsEditableItem) {
			super.isEditable = val
		} else {
			let val = Bool(super.isEditable)
			robj.setBoolValue(value: val, forProperty: KMTextEdit.IsEditableItem)
		}
		robj.addObserver(forProperty: KMTextEdit.IsEditableItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.boolValue(forProperty: KMTextEdit.IsEditableItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					super.isEditable = val
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMTextEdit.IsEditableItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMTextEdit.IsEditableItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
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
			} else {
				let ival = robj.immediateValue(forProperty: KMTextEdit.FontSizeItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMTextEdit.FontSizeItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
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
			} else {
				let ival = robj.immediateValue(forProperty: KMTextEdit.DecimalPlacesItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMTextEdit.DecimalPlacesItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
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

		/* text: this must be placed at last */
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
			} else {
				let ival = robj.immediateValue(forProperty: KMTextEdit.TextItem)
				CNLog(logLevel: .debug, message: "Invalid property: name=\(KMTextEdit.TextItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* number: this must be placed at last */
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
			} else {
				let ival = robj.immediateValue(forProperty: KMTextEdit.NumberItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMTextEdit.NumberItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(textEdit: self)
	}

	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Unsupported method: addChild")
	}
}

