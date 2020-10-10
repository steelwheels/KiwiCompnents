/**
 * @file	KMTerminalView.swift
 * @brief	Define KMTerminalView class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiControls
import Amber
import KiwiEngine
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMTerminalView: KCTerminalView, AMBComponent
{
	static let ForegroundColorItem		= "foregroundColor"
	static let BackgroundColorItem		= "backgroundColor"
	static let WidthItem			= "width"
	static let HeightItem			= "height"

	private var mReactObject:	AMBReactObject?
	private var mContext:		KEContext?

	public var reactObject: AMBReactObject { get {
		if let robj = mReactObject {
			return robj
		} else {
			fatalError("No react object in \(#file)")
		}
	}}

	public var context: KEContext { get {
		if let ctxt = mContext {
			return ctxt
		} else {
			fatalError("No context in \(#file)")
		}
	}}

	public func setup(reactObject robj: AMBReactObject, context ctxt: KEContext) -> NSError? {
		mReactObject	= robj
		mContext	= ctxt

		/* Sync initial value: foregroundColor */
		if let val = robj.getColorProperty(forKey: KMTerminalView.ForegroundColorItem) {
			self.foregroundTextColor = val
		} else {
			robj.set(key: KMTerminalView.ForegroundColorItem, colorValue: self.foregroundTextColor)
		}
		/* Add listner: foregroundColor */
		robj.addCallbackSource(forProperty: KMTerminalView.ForegroundColorItem, callbackFunction: {
			(_ val: Any) -> Void in
			if let val = robj.getColorProperty(forKey: KMTerminalView.ForegroundColorItem) {
				self.foregroundTextColor = val
			}
		})

		/* Sync initial value: backgroundColor */
		if let val = robj.getColorProperty(forKey: KMTerminalView.BackgroundColorItem) {
			self.backgroundTextColor = val
		} else {
			robj.set(key: KMTerminalView.BackgroundColorItem, colorValue: self.backgroundTextColor)
		}
		/* Add listner: backgroundColor */
		robj.addCallbackSource(forProperty: KMTerminalView.BackgroundColorItem, callbackFunction: {
			(_ val: Any) -> Void in
			if let val = robj.getColorProperty(forKey: KMTerminalView.BackgroundColorItem) {
				self.backgroundTextColor = val
			}
		})

		/* Sync initial value: width */
		if let val = robj.getIntProperty(forKey: KMTerminalView.WidthItem) {
			self.currentColumnNumbers = val
		} else {
			robj.set(key: KMTerminalView.WidthItem, intValue: self.currentColumnNumbers)
		}
		/* Add listner: width */
		robj.addCallbackSource(forProperty: KMTerminalView.WidthItem, callbackFunction: {
			(_ val: Any) -> Void in
			if let val = robj.getIntProperty(forKey: KMTerminalView.WidthItem) {
				self.currentColumnNumbers = val
			}
		})

		/* Sync initial value: height */
		if let val = robj.getIntProperty(forKey: KMTerminalView.HeightItem) {
			self.currentRowNumbers = val
		} else {
			robj.set(key: KMTerminalView.HeightItem, intValue: self.currentRowNumbers)
		}
		/* Add listner: height */
		robj.addCallbackSource(forProperty: KMTerminalView.HeightItem, callbackFunction: {
			(_ val: Any) -> Void in
			if let val = robj.getIntProperty(forKey: KMTerminalView.HeightItem) {
				self.currentRowNumbers = val
			}
		})

		return nil
	}

	public var children: Array<AMBComponent> { get { return [] }}
	public func addChild(component comp: AMBComponent) {
		NSLog("Can not add child components to Terminal component")
	}

	public func toText() -> CNTextSection {
		return reactObject.toText()
	}

}

