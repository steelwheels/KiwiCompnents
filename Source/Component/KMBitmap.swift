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
	public static let	DurationItem	= "duration"
	public static let	RepeatCountItem = "repeatCount"
	public static let 	StartItem	= "start"
	public static let	StopItem	= "stop"
	public static let	DrawItem	= "draw"

	public static let DefaultRowCount: Int		= 10
	public static let DefaultColumnCount: Int	= 10
	public static let DefaultRepeatCount: Int32	= 10

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
		NSLog("Can not add child components to Button component")
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj
		mConsole	= cons

		/* width */
		if let val = robj.floatValue(forProperty: KMBitmap.WidthItem) {
			self.minimumSize.width = CGFloat(val)
		} else {
			robj.setFloatValue(value: Double(self.minimumSize.width), forProperty: KMBitmap.WidthItem)
		}

		/* height */
		if let val = robj.floatValue(forProperty: KMBitmap.HeightItem) {
			self.minimumSize.height = CGFloat(val)
		} else {
			robj.setFloatValue(value: Double(self.minimumSize.height), forProperty: KMBitmap.HeightItem)
		}

		/* rowCount */
		if let val = robj.int32Value(forProperty: KMBitmap.RowCountItem) {
			self.rowCount = Int(val)
		} else {
			robj.setInt32Value(value: Int32(self.rowCount), forProperty: KMBitmap.RowCountItem)
		}

		/* columnCount */
		if let val = robj.int32Value(forProperty: KMBitmap.ColumnCountItem) {
			self.columnCount = Int(val)
		} else {
			robj.setInt32Value(value: Int32(self.columnCount), forProperty: KMBitmap.ColumnCountItem)
		}

		/* duration */
		var duration: TimeInterval = 1.0
		if let val = robj.floatValue(forProperty: KMBitmap.DurationItem) {
			duration = TimeInterval(val)
		} else {
			robj.setFloatValue(value: Double(duration), forProperty: KMBitmap.DurationItem)
		}

		/* repeatCount */
		var rcount = KMBitmap.DefaultRepeatCount
		if let val = robj.int32Value(forProperty: KMBitmap.RepeatCountItem) {
			rcount = val
		} else {
			robj.setInt32Value(value: rcount, forProperty: KMBitmap.RepeatCountItem)
		}

		/* add start method */
		let startfunc: @convention(block) (_ intrval: JSValue, _ endval: JSValue) -> JSValue = {
			(_ intrval: JSValue, _ endval: JSValue) -> JSValue in
			if intrval.isNumber && endval.isNumber {
				let interval = intrval.toDouble()
				let endtime  = endval.toDouble()
				self.start(interval: interval, endTime: Float(endtime))
				return JSValue(bool: true, in: robj.context)
			} else {
				return JSValue(bool: false, in: robj.context)
			}
		}
		robj.setImmediateValue(value: JSValue(object: startfunc, in: robj.context), forProperty: KMBitmap.StartItem)
		robj.addScriptedPropertyName(name: KMBitmap.StartItem)

		/* add stop method */
		let stopfunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			let result = self.isRunning
			self.stop()
			return JSValue(bool: result, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: stopfunc, in: robj.context), forProperty: KMBitmap.StopItem)
		robj.addScriptedPropertyName(name: KMBitmap.StopItem)

		/* draw */
		if let drawfnc = robj.immediateValue(forProperty: KMBitmap.DrawItem) {
			mDrawFunc = drawfnc
		} else {
			cons.error(string: "[Error] No \"draw\" function is defined at Graphics2D view\n")
		}

		return nil
	}

	public override func draw(bitmapContext ctxt: CNBitmapContext, count cnt: Int32) {
		if let drawfnc = mDrawFunc, let cntval = JSValue(int32: cnt, in: reactObject.context) {
			//NSLog("columnCount=\(self.columnCount) rowCounr=\(self.rowCount)")
			let bmctxt = KLBitmapContext(bitmapContext: ctxt, scriptContext: reactObject.context, console: mConsole)
			/* Call event function */
			drawfnc.call(withArguments: [reactObject, bmctxt, cntval])	// (self, context, count)
		} else {
			NSLog("No function to draw at \(#function)")
		}
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(bitmap: self)
	}
}
