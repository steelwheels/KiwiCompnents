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

	public var children: Array<AMBComponent> { get { return [] }}
	public func addChild(component comp: AMBComponent) {
		NSLog("Can not add child components to Button component")
	}

	public func setup(reactObject robj: AMBReactObject) -> NSError? {
		mReactObject	= robj
		/* Add callbacks */
		self.buttonPressedCallback = {
			() -> Void in
			if let evtval = robj.immediateValue(forProperty: KMButton.PressedItem) {
				DispatchQueue.global().async {
					evtval.call(withArguments: [])
				}
			}
		}

		/* Sync initial value: isEnabled */
		if let val = robj.numberValue(forProperty: KMButton.IsEnabledItem) {
			self.isEnabled = val.boolValue
		} else {
			robj.setNumberValue(number: NSNumber(booleanLiteral: self.isEnabled), forProperty: KMButton.IsEnabledItem)
		}
		/* Add listner: isEnabled */
		robj.addObserver(forProperty: KMButton.IsEnabledItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.numberValue(forProperty: KMButton.IsEnabledItem) {
				self.isEnabled = val.boolValue
			}
		})

		/* Sync initial value: title */
		if let val = robj.stringValue(forProperty: KMButton.TitleItem) {
			self.title = val
		} else {
			robj.setStringValue(string: self.title, forProperty: KMButton.TitleItem)
		}
		/* Add listner: title */
		robj.addObserver(forProperty: KMButton.TitleItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.stringValue(forProperty: KMButton.TitleItem) {
				self.title = val
			}
		})

		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(button: self)
	}
}
