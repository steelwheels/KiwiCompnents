/**
 * @file	KMValueView.swift
 * @brief	Define KMValueView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Amber
import KiwiControls
import KiwiEngine
import JavaScriptCore
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMValueView: KCValueView, AMBComponent
{
	private static let LoadItem		= "load"

	private var mReactObject:	AMBReactObject?

	public var reactObject: AMBReactObject	{ get {
		if let robj = mReactObject {
			return robj
		} else {
			fatalError("No react object")
		}
	}}

	public init(){
		mReactObject	= nil
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 188, height: 21)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 32)
		#endif
		super.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		mReactObject	= nil
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj

		/* add load table method */
		let loadfunc: @convention(block) (_ srcval: JSValue) -> JSValue = {
			(_ srcval: JSValue) -> JSValue in
			let nval = srcval.toNativeValue()
			CNExecuteInMainThread(doSync: false, execute: {
				() -> Void in
				self.load(value: nval)
			})
			return JSValue(bool: true, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: loadfunc, in: robj.context), forProperty: KMValueView.LoadItem)
		robj.addScriptedPropertyName(name: KMValueView.LoadItem)

		return nil
	}

	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Unsupported method: addChild")
	}
	
	public var children: Array<AMBComponent> {
		get {
			var result: Array<AMBComponent> = []
			for subview in self.arrangedSubviews() {
				if let comp = subview as? AMBComponent {
					result.append(comp)
				}
			}
			return result
		}
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(valueView: self)
	}
	
}

