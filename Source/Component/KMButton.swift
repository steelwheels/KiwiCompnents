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
	static let IsEnabledItem	= "isEnabled"
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
		CNLog(logLevel: .error, message: "Can not add child components to Button component")
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj
		/* Add callbacks */
		self.buttonPressedCallback = {
			() -> Void in
			if let evtval = robj.immediateValue(forProperty: KMButton.PressedItem) {
				CNExecuteInUserThread(level: .event, execute: {
					evtval.call(withArguments: [robj])	// insert self
				})
			}
		}

		/* Sync initial value: isEnabled */
		if let val = robj.boolValue(forProperty: KMButton.IsEnabledItem) {
			self.isEnabled = val
		} else {
			robj.setBoolValue(value: self.isEnabled, forProperty: KMButton.IsEnabledItem)
		}

		/* Add listner: isEnabled */
		robj.addObserver(forProperty: KMButton.IsEnabledItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.boolValue(forProperty: KMButton.IsEnabledItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					self.isEnabled = val
				})
			}
		})

		/* Sync initial value: title */
		if let val = robj.stringValue(forProperty: KMButton.TitleItem) {
			switch val {
			case "<-":	self.value = .symbol(.leftArrow)
			case "->":	self.value = .symbol(.rightArrow)
			default:	self.value = .text(val)
			}
		} else {
			let str: String
			switch self.value {
			case .text(let txt):	str = txt
			case .symbol(let sym):
				switch sym {
				case .leftArrow:	str = "<-"
				case .rightArrow:	str = "->"
				@unknown default:	str = "?"
				}
			@unknown default:
				str = "?"
			}
			robj.setStringValue(value: str, forProperty: KMButton.TitleItem)
		}
		/* Add listner: title */
		robj.addObserver(forProperty: KMButton.TitleItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.stringValue(forProperty: KMButton.TitleItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					self.value = .text(val)
				})
			}
		})

		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(button: self)
	}
}
