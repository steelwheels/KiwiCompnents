/**
 * @file	KMDrawingView.swift
 * @brief	Define KMDrawingView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation
import KiwiControls
import Amber
import KiwiEngine
import KiwiLibrary
import JavaScriptCore
import CoconutDatabase
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMDrawingView: KCDrawingView, AMBComponent
{
	private static let WidthItem	= "width"
	private static let HeightItem	= "height"
	private static let LoadItem	= "load"
	private static let StoreItem	= "store"

	private var mReactObject:	AMBReactObject?

	public var reactObject: AMBReactObject	{ get {
		if let robj = mReactObject {
			return robj
		} else {
			fatalError("No react object")
		}
	}}

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

		/* width */
		addScriptedProperty(object: robj, forProperty: KMDrawingView.WidthItem)
		if let val = robj.floatValue(forProperty: KMDrawingView.WidthItem) {
			self.drawingWidth = CGFloat(val)
		} else {
			let width: CGFloat = self.drawingHeight ?? -1.0
			robj.setFloatValue(value: Double(width), forProperty: KMDrawingView.WidthItem)
		}

		/* height */
		addScriptedProperty(object: robj, forProperty: KMDrawingView.HeightItem)
		if let val = robj.floatValue(forProperty: KMDrawingView.HeightItem) {
			self.drawingHeight = CGFloat(val)
		} else {
			let height: CGFloat = self.drawingHeight ?? -1.0
			robj.setFloatValue(value: Double(height), forProperty: KMDrawingView.HeightItem)
		}

		/* Add method: load */
		addScriptedProperty(object: robj, forProperty: KMDrawingView.LoadItem)
		let loadfunc: @convention(block) (_ urlval: JSValue) -> JSValue = {
			(_ urlval: JSValue) in
			var result = false
			if let urlobj = urlval.toObject() as? KLURL {
				if let u = urlobj.url {
					CNExecuteInMainThread(doSync: false, execute: {
						() -> Void in
						if !super.load(from: u) {
							CNLog(logLevel: .error, message: "Failed to load", atFunction: #function, inFile: #file)
						}
					})
					result = true
				}
			}
			return JSValue(bool: result, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: loadfunc, in: robj.context), forProperty: KMDrawingView.LoadItem)

		/* Add method: store */
		addScriptedProperty(object: robj, forProperty: KMDrawingView.StoreItem)
		let storefunc: @convention(block) (_ urlval: JSValue) -> JSValue = {
			(_ urlval: JSValue) in
			var result = false
			if let urlobj = urlval.toObject() as? KLURL {
				if let u = urlobj.url {
					let val = self.toValue()
					result = u.storeValue(value: val)
				}
			}
			return JSValue(bool: result, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: storefunc, in: robj.context), forProperty: KMDrawingView.StoreItem)

		return nil
	}

	public var children: Array<AMBComponent>  { get { return [] }}

	public func addChild(component comp: AMBComponent) {
		NSLog("Can not add child components to Button component")
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(drawingView: self)
	}
}

