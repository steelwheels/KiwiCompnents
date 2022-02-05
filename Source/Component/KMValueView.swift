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
	static let ValueItem    =	"value"

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

		/* Sync initial value: "value" */
		addScriptedProperty(object: robj, forProperty: KMValueView.ValueItem)
		if let val = robj.immediateValue(forProperty: KMValueView.ValueItem) {
			self.value = val.toNativeValue()
		} else {
			let val = self.value.toJSValue(context: robj.context)
			robj.setImmediateValue(value: val, forProperty: KMValueView.ValueItem)
		}
		robj.addObserver(forProperty: KMValueView.ValueItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.immediateValue(forProperty: KMValueView.ValueItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					self.value = val.toNativeValue()
				})
			}
		})
		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(valueView: self)
	}

	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Unsupported method: addChild")
	}
}

