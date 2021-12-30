/**
 * @file	KMStepperswift
 * @brief	Define KMStepper class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import KiwiControls
import Amber
import KiwiEngine
import JavaScriptCore
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#else
import AppKit
#endif

public class KMStepper: KCStepper, AMBComponent
{
	static let MaxValueItem		= "maxValue"
	static let MinValueItem		= "minValue"
	static let CurrentValueItem	= "currentValue"
	static let ChangedItem		= "changed"
	
	private var mReactObject:	AMBReactObject?
	private var mChildObjects:	Array<AMBComponentObject>

	public var children: Array<AMBComponent> { get { return [] }}
	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Not supported", atFunction: #function, inFile: #file)
	}
	
	public var reactObject: AMBReactObject {
		get {
			if let robj = mReactObject {
				return robj
			} else {
				fatalError("No react object")
			}
		}
	}

	public init(){
		mReactObject	= nil
		mChildObjects	= []
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 188, height: 21)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 32)
		#endif
		super.init(frame: frame)
	}

	@objc required dynamic init?(coder: NSCoder) {
		mReactObject		= nil
		mChildObjects		= []
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject = robj

		/* Define property: maxValue */
		if let val = robj.floatValue(forProperty: KMStepper.MaxValueItem) {
			self.maxValue = val
		} else {
			robj.setFloatValue(value: self.maxValue, forProperty: KMStepper.MaxValueItem)
		}
		robj.addObserver(forProperty: KMStepper.MaxValueItem, callback:  {
			(_ val: Any) -> Void in
			if let val = robj.floatValue(forProperty: KMStepper.MaxValueItem) {
				self.maxValue = val
			}
		})

		/* Define property: minValue */
		if let val = robj.floatValue(forProperty: KMStepper.MinValueItem) {
			self.minValue = val
		} else {
			robj.setFloatValue(value: self.minValue, forProperty: KMStepper.MinValueItem)
		}
		robj.addObserver(forProperty: KMStepper.MinValueItem, callback:  {
			(_ val: Any) -> Void in
			if let val = robj.floatValue(forProperty: KMStepper.MinValueItem) {
				self.minValue = val
			}
		})

		/* Define property: currentValue */
		if let val = robj.floatValue(forProperty: KMStepper.CurrentValueItem) {
			self.currentValue = val
		} else {
			robj.setFloatValue(value: self.currentValue, forProperty: KMStepper.CurrentValueItem)
		}

		/* Add callbacks */
		self.updateValueCallback = {
			(_ newval: Double) -> Void in
			if let evtval = robj.immediateValue(forProperty: KMStepper.ChangedItem) {
				if let valobj = JSValue(double: newval, in: robj.context) {
					CNExecuteInUserThread(level: .event, execute: {
						evtval.call(withArguments: [robj, valobj])	// insert self
					})
				} else {
					CNLog(logLevel: .error, message: "Failed to allocate parameter", atFunction: #function, inFile: #file)
				}
			}
		}
		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(stepper: self)
	}
}
