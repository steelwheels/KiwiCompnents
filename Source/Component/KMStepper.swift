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
	private static let IsIncrementableItem	= "isIncrementable"
	private static let IsDecrementableItem	= "isDecrementable"
	private static let MaxValueItem		= "maxValue"
	private static let MinValueItem		= "minValue"
	private static let DeltaValueItem	= "deltaValue"
	private static let CurrentValueItem	= "currentValue"
	private static let DecimalPlacesItem	= "decimalPlaces"
	private static let ChangedItem		= "changed"

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

		/* isIncrementable */
		addScriptedProperty(object: robj, forProperty: KMStepper.IsIncrementableItem)
		if let val = robj.boolValue(forProperty: KMStepper.IsIncrementableItem) {
			self.isIncrementable = val
		} else {
			robj.setBoolValue(value: self.isIncrementable, forProperty: KMStepper.IsIncrementableItem)
		}
		robj.addObserver(forProperty: KMStepper.IsIncrementableItem, callback:  {
			(_ val: Any) -> Void in
			if let val = robj.boolValue(forProperty: KMStepper.IsIncrementableItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					() -> Void in self.isIncrementable = val
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMStepper.IsIncrementableItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMStepper.IsIncrementableItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* isDecrementable */
		addScriptedProperty(object: robj, forProperty: KMStepper.IsDecrementableItem)
		if let val = robj.boolValue(forProperty: KMStepper.IsDecrementableItem) {
			self.isDecrementable = val
		} else {
			robj.setBoolValue(value: self.isDecrementable, forProperty: KMStepper.IsDecrementableItem)
		}
		robj.addObserver(forProperty: KMStepper.IsDecrementableItem, callback:  {
			(_ val: Any) -> Void in
			if let val = robj.boolValue(forProperty: KMStepper.IsDecrementableItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					() -> Void in self.isDecrementable = val
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMStepper.IsDecrementableItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMStepper.IsDecrementableItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* maxValue */
		addScriptedProperty(object: robj, forProperty: KMStepper.MaxValueItem)
		if let val = robj.floatValue(forProperty: KMStepper.MaxValueItem) {
			self.maxValue = val
		} else {
			robj.setFloatValue(value: self.maxValue, forProperty: KMStepper.MaxValueItem)
		}
		robj.addObserver(forProperty: KMStepper.MaxValueItem, callback:  {
			(_ val: Any) -> Void in
			if let val = robj.floatValue(forProperty: KMStepper.MaxValueItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					() -> Void in self.maxValue = val
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMStepper.MaxValueItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMStepper.MaxValueItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* minValue */
		addScriptedProperty(object: robj, forProperty: KMStepper.MinValueItem)
		if let val = robj.floatValue(forProperty: KMStepper.MinValueItem) {
			self.minValue = val
		} else {
			robj.setFloatValue(value: self.minValue, forProperty: KMStepper.MinValueItem)
		}
		robj.addObserver(forProperty: KMStepper.MinValueItem, callback:  {
			(_ val: Any) -> Void in
			if let val = robj.floatValue(forProperty: KMStepper.MinValueItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					() -> Void in self.minValue = val
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMStepper.MinValueItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMStepper.MinValueItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* deltaValue */
		addScriptedProperty(object: robj, forProperty: KMStepper.DeltaValueItem)
		if let val = robj.floatValue(forProperty: KMStepper.DeltaValueItem) {
			self.deltaValue = val
		} else {
			robj.setFloatValue(value: self.deltaValue, forProperty: KMStepper.DeltaValueItem)
		}
		robj.addObserver(forProperty: KMStepper.DeltaValueItem, callback:  {
			(_ val: Any) -> Void in
			if let val = robj.floatValue(forProperty: KMStepper.DeltaValueItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					() -> Void in self.deltaValue = val
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMStepper.DeltaValueItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMStepper.DeltaValueItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* currentValue */
		addScriptedProperty(object: robj, forProperty: KMStepper.CurrentValueItem)
		if let val = robj.floatValue(forProperty: KMStepper.CurrentValueItem) {
			self.currentValue = val
		} else {
			robj.setFloatValue(value: self.currentValue, forProperty: KMStepper.CurrentValueItem)
		}
		robj.addObserver(forProperty: KMStepper.CurrentValueItem, callback:  {
			(_ val: Any) -> Void in
			if let val = robj.floatValue(forProperty: KMStepper.CurrentValueItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					() -> Void in self.currentValue = val
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMStepper.CurrentValueItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMStepper.CurrentValueItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* decimalPlaces */
		addScriptedProperty(object: robj, forProperty: KMStepper.DecimalPlacesItem)
		if let val = robj.int32Value(forProperty: KMStepper.DecimalPlacesItem) {
			self.decimalPlaces = Int(val)
		} else {
			robj.setInt32Value(value: Int32(self.decimalPlaces), forProperty: KMStepper.DecimalPlacesItem)
		}
		robj.addObserver(forProperty: KMStepper.DecimalPlacesItem, callback:  {
			(_ val: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMStepper.DecimalPlacesItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					() -> Void in self.decimalPlaces = Int(val)
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMStepper.DecimalPlacesItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMStepper.DecimalPlacesItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* "changed" callbacks */
		self.updateValueCallback = {
			(_ newval: Double) -> Void in
			if let evtval = robj.immediateValue(forProperty: KMStepper.ChangedItem) {
				if let valobj = JSValue(double: newval, in: robj.context) {
					/* Update current value */
					robj.setFloatValue(value: self.currentValue, forProperty: KMStepper.CurrentValueItem)
					/* Callback */
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

