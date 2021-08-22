/**
 * @file	KMValueView.swift
 * @brief	Define KMValueView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Amber
import KiwiControls
import KiwiEngine
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMValueView: KCValueView, AMBComponent
{
	public static let ValueItem		= "value"

	private var mReactObject:	AMBReactObject?

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
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#endif
		super.init(frame: frame)
	}

	@objc required dynamic init?(coder: NSCoder) {
		mReactObject		= nil
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj

		/* Setup: value */
		if let val = robj.immediateValue(forProperty: KMValueView.ValueItem) {
			super.load(value: val.toNativeValue())
		} else {
			robj.setImmediateValue(value: self.value.toJSValue(context: robj.context), forProperty: KMValueView.ValueItem)
		}
		robj.addObserver(forProperty: KMValueView.ValueItem, callback: {
			(_ param: Any) -> Void in
			NSLog("value (0): \(param) \(#function) \(#file)")
			if let val = robj.immediateValue(forProperty: KMValueView.ValueItem) {
				NSLog("value (1)")
				CNExecuteInMainThread(doSync: false, execute: {
					self.load(value: val.toNativeValue())
				})
			}
			NSLog("value (e)")
		})
		robj.addScriptedPropertyName(name: KMValueView.ValueItem)

		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(valueView: self)
	}

	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Unsupported method: addChild")
	}
}


