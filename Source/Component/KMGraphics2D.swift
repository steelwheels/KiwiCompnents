/**
 * @file	KMGraphics2D.swift
 * @brief	Define KMGraphics2D class
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

public class KMGraphics2D: KCGraphics2DView, AMBComponent
{
	public static let 	WidthItem	= "width"
	public static let	HeightItem	= "height"
	public static let 	SizeXItem	= "size_x"
	public static let 	SizeYItem	= "size_y"
	public static let 	OriginXItem	= "origin_x"
	public static let 	OriginYItem	= "origin_y"
	public static let	StateItem	= "state"
	public static let 	StartItem	= "start"
	public static let	StopItem	= "stop"
	public static let 	SuspendItem	= "suspend"
	public static let	ResumeItem	= "resume"
	public static let	DrawItem	= "draw"

	private var mReactObject:	AMBReactObject?
	private var mDrawFunc:		JSValue?
	private var mConsole:		CNConsole

	public static let DefaultRepeatCount: Int32	= 10

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
		if let val = robj.floatValue(forProperty: KMGraphics2D.WidthItem) {
			self.minimumSize.width = CGFloat(val)
		} else {
			robj.setFloatValue(value: Double(self.minimumSize.width), forProperty: KMGraphics2D.WidthItem)
		}

		/* height */
		if let val = robj.floatValue(forProperty: KMGraphics2D.HeightItem) {
			self.minimumSize.height = CGFloat(val)
		} else {
			robj.setFloatValue(value: Double(self.minimumSize.height), forProperty: KMGraphics2D.HeightItem)
		}

		/* size-x */
		if let val = robj.floatValue(forProperty: KMGraphics2D.SizeXItem) {
			self.logicalFrame.size.width = CGFloat(val)
		} else {
			robj.setFloatValue(value: Double(self.logicalFrame.size.width), forProperty: KMGraphics2D.SizeXItem)
		}

		/* size-y */
		if let val = robj.floatValue(forProperty: KMGraphics2D.SizeYItem) {
			self.logicalFrame.size.height = CGFloat(val)
		} else {
			robj.setFloatValue(value: Double(self.logicalFrame.size.height), forProperty: KMGraphics2D.SizeYItem)
		}

		/* origin-x */
		if let val = robj.floatValue(forProperty: KMGraphics2D.OriginXItem) {
			self.logicalFrame.origin.x = CGFloat(val)
		} else {
			robj.setFloatValue(value: Double(self.logicalFrame.origin.x), forProperty: KMGraphics2D.OriginXItem)
		}

		/* origin-y */
		if let val = robj.floatValue(forProperty: KMGraphics2D.OriginYItem) {
			self.logicalFrame.origin.y = CGFloat(val)
		} else {
			robj.setFloatValue(value: Double(self.logicalFrame.origin.y), forProperty: KMGraphics2D.OriginYItem)
		}

		/* add state method */
		let statefunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			return JSValue(int32: self.state.rawValue, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: statefunc, in: robj.context), forProperty: KMGraphics2D.StateItem)
		robj.addScriptedPropertyName(name: KMGraphics2D.StateItem)

		/* add start method */
		let startfunc: @convention(block) (_ intrval: JSValue, _ endval: JSValue) -> JSValue = {
			(_ intrval: JSValue, _ endval: JSValue) -> JSValue in
			NSLog("startfunc-0")
			if intrval.isNumber && endval.isNumber {
				let interval = intrval.toDouble()
				let endtime  = endval.toDouble()
				self.start(interval: interval, endTime: Float(endtime))
				NSLog("startfunc-1")
				return JSValue(bool: true, in: robj.context)
			} else {
				NSLog("startfunc-2")
				return JSValue(bool: false, in: robj.context)
			}
		}
		robj.setImmediateValue(value: JSValue(object: startfunc, in: robj.context), forProperty: KMGraphics2D.StartItem)
		robj.addScriptedPropertyName(name: KMGraphics2D.StartItem)

		/* add stop method */
		let stopfunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			NSLog("stopfunc-0")
			self.stop()
			NSLog("stopfunc-1")
			return JSValue(bool: true, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: stopfunc, in: robj.context), forProperty: KMGraphics2D.StopItem)
		robj.addScriptedPropertyName(name: KMGraphics2D.StopItem)

		/* add suspend method */
		let suspendfunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			NSLog("suspendfunc-0")
			self.suspend()
			NSLog("suspendfunc-2")
			return JSValue(bool: true, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: suspendfunc, in: robj.context), forProperty: KMGraphics2D.SuspendItem)
		robj.addScriptedPropertyName(name: KMGraphics2D.SuspendItem)

		/* add resume method */
		let resumefunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			NSLog("resumefunc-0")
			self.resume()
			NSLog("resumefunc-2")
			return JSValue(bool: true, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: resumefunc, in: robj.context), forProperty: KMGraphics2D.ResumeItem)
		robj.addScriptedPropertyName(name: KMGraphics2D.ResumeItem)

		/* draw */
		if let drawfnc = robj.immediateValue(forProperty: KMGraphics2D.DrawItem) {
			mDrawFunc = drawfnc
		} else {
			cons.error(string: "[Error] No \"draw\" function is defined at Graphics2D view\n")
		}

		return nil
	}

	public override func draw(graphicsContext ctxt: CNGraphicsContext, count cnt: Int32) {
		if let drawfnc = mDrawFunc, let cntval = JSValue(int32: cnt, in: reactObject.context) {
			let gctxt  = KLGraphicsContext(graphicsContext: ctxt, scriptContext: reactObject.context, console: mConsole)
			/* Call event function */
			drawfnc.call(withArguments: [reactObject, gctxt, cntval])	// (self, context, count)
		} else {
			NSLog("No function to draw at \(#function)")
		}
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(graphics2D: self)
	}
}

