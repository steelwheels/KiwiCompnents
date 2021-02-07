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
	public static let	DurationItem	= "duration"
	public static let	RepeatCountItem = "repeatCount"
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

		/* duration */
		var duration: TimeInterval = 1.0
		if let val = robj.floatValue(forProperty: KMGraphics2D.DurationItem) {
			duration = TimeInterval(val)
		} else {
			robj.setFloatValue(value: Double(duration), forProperty: KMGraphics2D.DurationItem)
		}

		/* repeatCount */
		var rcount = KMGraphics2D.DefaultRepeatCount
		if let val = robj.int32Value(forProperty: KMGraphics2D.RepeatCountItem) {
			rcount = val
		} else {
			robj.setInt32Value(value: rcount, forProperty: KMBitmap.RepeatCountItem)
		}

		/* draw */
		if let drawfnc = robj.immediateValue(forProperty: KMGraphics2D.DrawItem) {
			mDrawFunc = drawfnc
		} else {
			cons.error(string: "[Error] No \"draw\" function is defined at Graphics2D view\n")
		}

		/* Setup */
		self.animation(interval: duration, endTime: Float(rcount))

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

