/**
 * @file	KMBitmap.swift
 * @brief	Define KMBitmap class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import KiwiControls
import Amber
import KiwiEngine
import KiwiLibrary
import CoconutData
import JavaScriptCore
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMBitmap: KCBitmapView, AMBComponent
{
	public static let 	WidthItem	= "width"
	public static let	HeightItem	= "height"
	public static let	RowCountItem	= "rowCount"
	public static let	ColumnCountItem	= "columnCount"
	public static let	StateItem	= "state"
	public static let 	StartItem	= "start"
	public static let	StopItem	= "stop"
	public static let 	SuspendItem	= "suspend"
	public static let	ResumeItem	= "resume"
	public static let	DrawItem	= "draw"

	public static let DefaultRowCount: Int		= 10
	public static let DefaultColumnCount: Int	= 10

	private var mReactObject:	AMBReactObject?
	private var mDrawFunc:		JSValue?
	private var mConsole:		CNConsole

	public var reactObject: AMBReactObject	{ get {
		if let robj = mReactObject {
			return robj
		} else {
			fatalError("No react object")
		}
	}}

	public init() {
		mReactObject	= nil
		mDrawFunc	= nil
		mConsole	= CNFileConsole()
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 50, height: 50)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
		#endif
		super.init(frame: frame)
	}

	@objc required dynamic init?(coder: NSCoder) {
		mReactObject 	= nil
		mDrawFunc	= nil
		mConsole	= CNFileConsole()
		super.init(coder: coder)
	}

	public var children: Array<AMBComponent>  { get { return [] }}
	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Can not add child components to Button component", atFunction: #function, inFile: #file)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj
		mConsole	= cons

		/* width */
		addScriptedProperty(object: robj, forProperty: KMBitmap.WidthItem)
		if let val = robj.floatValue(forProperty: KMBitmap.WidthItem) {
			self.minimumSize.width = CGFloat(val)
		} else {
			robj.setFloatValue(value: Double(self.minimumSize.width), forProperty: KMBitmap.WidthItem)
		}

		/* height */
		addScriptedProperty(object: robj, forProperty: KMBitmap.HeightItem)
		if let val = robj.floatValue(forProperty: KMBitmap.HeightItem) {
			self.minimumSize.height = CGFloat(val)
		} else {
			robj.setFloatValue(value: Double(self.minimumSize.height), forProperty: KMBitmap.HeightItem)
		}

		/* rowCount */
		addScriptedProperty(object: robj, forProperty: KMBitmap.RowCountItem)
		if let val = robj.int32Value(forProperty: KMBitmap.RowCountItem) {
			self.rowCount = Int(val)
		} else {
			robj.setInt32Value(value: Int32(self.rowCount), forProperty: KMBitmap.RowCountItem)
		}

		/* columnCount */
		addScriptedProperty(object: robj, forProperty: KMBitmap.ColumnCountItem)
		if let val = robj.int32Value(forProperty: KMBitmap.ColumnCountItem) {
			self.columnCount = Int(val)
		} else {
			robj.setInt32Value(value: Int32(self.columnCount), forProperty: KMBitmap.ColumnCountItem)
		}

		/* state: readonly */
		addScriptedProperty(object: robj, forProperty: KMBitmap.StateItem)
		robj.setInt32Value(value: Int32(self.state.rawValue), forProperty: KMBitmap.StateItem)
		self.setCallback(updateStateCallback: {
			(_ newstate: CNAnimationState) -> Void in
			robj.setInt32Value(value: Int32(newstate.rawValue), forProperty: KMBitmap.StateItem)
		})

		/* add start method */
		addScriptedProperty(object: robj, forProperty: KMBitmap.StartItem)
		let startfunc: @convention(block) (_ durval: JSValue, _ repval: JSValue) -> JSValue = {
			(_ durval: JSValue, _ repval: JSValue) -> JSValue in
			if durval.isNumber && repval.isNumber {
				let duration = durval.toDouble()
				let repcount = repval.toInt32()
				self.start(duration: duration, repeatCount: Int(repcount))
				return JSValue(bool: true, in: robj.context)
			} else {
				return JSValue(bool: false, in: robj.context)
			}
		}
		robj.setImmediateValue(value: JSValue(object: startfunc, in: robj.context), forProperty: KMBitmap.StartItem)

		/* add stop method */
		addScriptedProperty(object: robj, forProperty: KMBitmap.StopItem)
		let stopfunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			self.stop()
			return JSValue(bool: true, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: stopfunc, in: robj.context), forProperty: KMBitmap.StopItem)

		/* add suspend method */
		addScriptedProperty(object: robj, forProperty: KMBitmap.SuspendItem)
		let suspendfunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			self.suspend()
			return JSValue(bool: true, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: suspendfunc, in: robj.context), forProperty: KMBitmap.SuspendItem)

		/* add resume method */
		addScriptedProperty(object: robj, forProperty: KMBitmap.ResumeItem)
		let resumefunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			self.resume()
			return JSValue(bool: true, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: resumefunc, in: robj.context), forProperty: KMBitmap.ResumeItem)

		/* draw */
		if let drawfnc = robj.immediateValue(forProperty: KMBitmap.DrawItem) {
			mDrawFunc = drawfnc
		} else {
			cons.error(string: "[Error] No \"draw\" function is defined at Bitmap view\n")
		}

		return nil
	}

	public override func update(bitmapContext ctxt: CNBitmapContext, count cnt: Int32) {
		if let drawfnc = mDrawFunc, let cntval = JSValue(int32: cnt, in: reactObject.context) {
			CNExecuteInUserThread(level: .event, execute: {
				() -> Void in
				let bmctxt = KLBitmapContext(bitmapContext: ctxt, scriptContext: self.reactObject.context, console: self.mConsole)
				/* Call event function */
				drawfnc.call(withArguments: [self.reactObject, bmctxt, cntval])	// (self, context, count)
			})
		} else {
			CNLog(logLevel: .error, message: "No function to draw ", atFunction: #function, inFile: #file)
		}
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(bitmap: self)
	}
}
