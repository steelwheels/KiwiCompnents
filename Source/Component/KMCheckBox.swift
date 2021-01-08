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
	static let CheckedItem		= "checked"
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
		let frame = KCRect(x: 0.0, y: 0.0, width: 188, height: 21)
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

		/* Sync initial value: status */
		robj.setBoolValue(value: self.status, forProperty: KMCheckBox.StatusItem)

		/* Sync initial value: isEnabled */
		if let val = robj.boolValue(forProperty: KMCheckBox.IsEnabledItem) {
			self.isEnabled = val
		} else {
			robj.setBoolValue(value: self.isEnabled, forProperty: KMCheckBox.IsEnabledItem)
		}

		/* Sync initial value: title */
		if let val = robj.stringValue(forProperty: KMCheckBox.TitleItem) {
			self.title = val
		} else {
			robj.setStringValue(string: self.title, forProperty: KMCheckBox.TitleItem)
		}

		/* Add callback */
		super.checkUpdatedCallback = {
			(_ status: Bool) -> Void in
			if let evtval = robj.immediateValue(forProperty: KMCheckBox.CheckedItem) {
				if let statval = JSValue(bool: status, in: robj.context) {
					DispatchQueue.global().async {
						evtval.call(withArguments: [robj, statval])	// insert self
					}
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

