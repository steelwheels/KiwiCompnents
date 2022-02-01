/**
 * @file	KMCheckBox.swift
 * @brief	Define KMCheckBox class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import KiwiControls
import Amber
import KiwiEngine
import CoconutData
import JavaScriptCore
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMCheckBox: KCCheckBox, AMBComponent
{
	static let StatusItem		= "status"
	static let IsEnabledItem	= "isEnabled"
	static let PressedItem		= "pressed"
	static let TitleItem		= "title"

	private var mReactObject:	AMBReactObject?

	public var reactObject: AMBReactObject	{ get {
		if let robj = mReactObject {
			return robj
		} else {
			fatalError("No react object")
		}
	}}

	public init() {
		mReactObject = nil
		let frame = CGRect(x: 0.0, y: 0.0, width: 188, height: 21)
		super.init(frame: frame)
	}

	@objc required dynamic init?(coder: NSCoder) {
		mReactObject = nil
		super.init(coder: coder)
	}

	public var children: Array<AMBComponent>  { get { return [] }}
	public func addChild(component comp: AMBComponent) {
		NSLog("Can not add child components to Button component")
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj

		/* status */
		addScriptedProperty(object: robj, forProperty: KMCheckBox.StatusItem)
		if let val = robj.boolValue(forProperty: KMCheckBox.StatusItem) {
			self.status = val
		} else {
			robj.setBoolValue(value: self.status, forProperty: KMCheckBox.StatusItem)
		}
		robj.addObserver(forProperty: KMCheckBox.StatusItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.boolValue(forProperty: KMCheckBox.StatusItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					if self.status != val {
						self.status = val
					}
				})
			}
		})

		/* isEnabled */
		addScriptedProperty(object: robj, forProperty: KMCheckBox.IsEnabledItem)
		if let val = robj.boolValue(forProperty: KMCheckBox.IsEnabledItem) {
			self.isEnabled = val
		} else {
			robj.setBoolValue(value: self.isEnabled, forProperty: KMCheckBox.IsEnabledItem)
		}
		robj.addObserver(forProperty: KMCheckBox.IsEnabledItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.boolValue(forProperty: KMCheckBox.IsEnabledItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					if self.isEnabled != val {
						self.isEnabled = val
					}
				})
			}
		})

		/* Sync title */
		addScriptedProperty(object: robj, forProperty: KMCheckBox.TitleItem)
		if let val = robj.stringValue(forProperty: KMCheckBox.TitleItem) {
			self.title = val
		} else {
			robj.setStringValue(value: self.title, forProperty: KMCheckBox.TitleItem)
		}
		robj.addObserver(forProperty: KMCheckBox.TitleItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.stringValue(forProperty: KMCheckBox.TitleItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					self.title = val
				})
			}
		})

		/* Add callback */
		super.checkUpdatedCallback = {
			(_ stat: Bool) -> Void in
			if let evtval = robj.immediateValue(forProperty: KMCheckBox.PressedItem) {
				robj.setBoolValue(value: stat, forProperty: KMCheckBox.StatusItem)
				if let statval = JSValue(bool: stat, in: robj.context) {
					CNExecuteInUserThread(level: .event, execute: {
						evtval.call(withArguments: [robj, statval])	// insert self
					})
				} else {
					NSLog("Failed to allocate object at \(#function)")
				}
			}
		}

		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(checkBox: self)
	}
}

