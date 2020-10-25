/**
 * @file	KMButton.swift
 * @brief	Define KMButton class
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

public class KMButton: KCButton, AMBComponent
{
	static let PressedItem		= "pressed"
	static let IsEnabledItem	= "enabled"
	static let TitleItem		= "title"

	private var mReactObject:	AMBReactObject?
	private var mContext:		KEContext?
	private var mEnvironment:	CNEnvironment?

	public var reactObject: AMBReactObject	{ get { return getProperty(mReactObject)	}}
	public var context: KEContext		{ get { return getProperty(mContext)		}}
	public var environment: CNEnvironment	{ get { return getProperty(mEnvironment)	}}

	public init(){
		mReactObject	= nil
		mContext	= nil
		mEnvironment	= nil

		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 188, height: 21)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 32)
		#endif
		super.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		mReactObject	= nil
		mContext	= nil
		mEnvironment	= nil
		super.init(coder: coder)
	}

	public var children: Array<AMBComponent> { get { return [] }}
	public func addChild(component comp: AMBComponent) {
		NSLog("Can not add child components to Button component")
	}

	public func setup(reactObject robj: AMBReactObject, context ctxt: KEContext, processManager pmgr: CNProcessManager, environment env: CNEnvironment) -> NSError? {
		mReactObject	= robj
		mContext	= ctxt
		mEnvironment	= env

		/* Add allbacks */
		self.buttonPressedCallback = {
			() -> Void in
			if let rval = robj.get(forKey: KMButton.PressedItem) {
				if let evtval = rval.eventFunctionValue {
					evtval.call(withArguments: [])
				}
			}
		}

		/* Sync initial value: isEnabled */
		if let val = robj.getBooleanProperty(forKey: KMButton.IsEnabledItem) {
			self.isEnabled = val
		} else {
			robj.set(key: KMButton.IsEnabledItem, booleanValue: self.isEnabled)
		}
		/* Add listner: isEnabled */
		robj.addCallbackSource(forProperty: KMButton.IsEnabledItem, callbackFunction: {
			(_ val: Any) -> Void in
			if let val = robj.getBooleanProperty(forKey: KMButton.IsEnabledItem) {
				self.isEnabled = val
			}
		})

		/* Sync initial value: title */
		if let val = robj.getStringProperty(forKey: KMButton.TitleItem) {
			self.title = val
		} else {
			robj.set(key: KMButton.TitleItem, stringValue: self.title)
		}
		/* Add listner: title */
		robj.addCallbackSource(forProperty: KMButton.TitleItem, callbackFunction: {
			(_ val: Any) -> Void in
			if let val = robj.getStringProperty(forKey: KMButton.TitleItem) {
				self.title = val
			}
		})

		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(button: self)
	}

	public func toText() -> CNTextSection {
		return reactObject.toText()
	}
}
