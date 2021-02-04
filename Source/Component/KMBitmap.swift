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

		/* draw */
		if let drawfnc = robj.immediateValue(forProperty: KMBitmap.DrawItem) {
			mDrawFunc = drawfnc
		} else {
			cons.error(string: "[Error] No \"draw\" function is defined at Graphics2D view\n")
		}

		return nil
	}

	public override func draw(context ctxt: CNBitmapContext) {
		if let drawfnc = mDrawFunc {
			NSLog("columnCount=\(self.columnCount) rowCounr=\(self.rowCount)")
			let bmctxt = KLBitmapContext(bitmapContext: ctxt, scriptContext: reactObject.context, console: mConsole)
			/* Call event function */
			drawfnc.call(withArguments: [reactObject, bmctxt])	// (self, context)
		} else {
			NSLog("No function to draw at \(#function)")
		}
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(bitmap: self)
	}
}
