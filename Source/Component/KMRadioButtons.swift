/**
 * @file	KMRadioButtons.swift
 * @brief	Define KMRadioButtons class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import KiwiControls
import Amber
import KiwiEngine
import CoconutData
import Foundation
import JavaScriptCore
#if os(iOS)
import UIKit
#endif

public class KMRadioButtons: KCRadioButtons, AMBComponent
{
	private static let LabelsItem		= "labels"
	private static let SelectedItem		= "selected"
	private static let CurrentIndexItem	= "currentIndex"
	private static let ColumnCountItem	= "columnCount"
	private static let IsEnabledItem	= "isEnabled"

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

	public required init?(coder: NSCoder) {
		mReactObject	= nil
		mChildObjects	= []
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj

		/* columnCount */
		if let val = robj.int32Value(forProperty: KMRadioButtons.ColumnCountItem) {
			self.numberOfColumns = Int(val)
		}

		/* Labels (required, write-only (execute after gettting columnCount) */
		addScriptedProperty(object: robj, forProperty: KMRadioButtons.LabelsItem)
		if let val = robj.arrayValue(forProperty: KMRadioButtons.LabelsItem) {
			var labels: Array<String> = []
			for lab in val {
				if let str = lab as? String {
					labels.append(str)
				} else {
					CNLog(logLevel: .error, message: "Labels property requires string value", atFunction: #function, inFile: #file)
				}
			}
			super.setLabels(labels: labels)
		} else {
			CNLog(logLevel: .error, message: "Labels propertiy is required", atFunction: #function, inFile: #file)
		}

		/* isEnabled */
		addScriptedProperty(object: robj, forProperty: KMRadioButtons.IsEnabledItem)
		if let arr = robj.arrayValue(forProperty: KMRadioButtons.IsEnabledItem){
			setEnable(scriptValue: arr)
		} else {
			let ival = CNValue.boolValue(true)
			let iarr = Array(repeating: ival, count: super.numberOfColumns)
			super.setEnable(enables: iarr)
			robj.setArrayValue(value: iarr, forProperty: KMRadioButtons.IsEnabledItem)
		}
		robj.addObserver(forProperty: KMRadioButtons.IsEnabledItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.arrayValue(forProperty: KMRadioButtons.IsEnabledItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					self.setEnable(scriptValue: val)
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMRadioButtons.IsEnabledItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMRadioButtons.IsEnabledItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* Current index (read-only) */
		addScriptedProperty(object: robj, forProperty: KMRadioButtons.CurrentIndexItem)
		if let idx = self.currentIndex {
			robj.setInt32Value(value: Int32(idx), forProperty: KMRadioButtons.CurrentIndexItem)
		}

		/* Add callbacks */
		self.callback = {
			(_ index: Int) -> Void in
			/* Update current index */
			robj.setInt32Value(value: Int32(index), forProperty: KMRadioButtons.CurrentIndexItem)
			/* Call event handler */
			if let evtval = robj.immediateValue(forProperty: KMRadioButtons.SelectedItem) {
				if let idxval = JSValue(int32: Int32(index), in: robj.context) {
					CNExecuteInUserThread(level: .event, execute: {
						evtval.call(withArguments: [robj, idxval])	// insert self, index
					})
				} else {
					let ival = robj.immediateValue(forProperty: KMRadioButtons.SelectedItem)
					CNLog(logLevel: .error, message: "Invalid property: name=\(KMRadioButtons.SelectedItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
				}
			}
		}

		return nil
	}

	private func setEnable(scriptValue arr: Array<Any>){
		var param: Array<CNValue> = []
		for aval in arr {
			if let val = CNValue.anyToValue(object: aval){
				param.append(val)
			} else {
				CNLog(logLevel: .error, message: "Invalid parameters: \(aval)", atFunction: #function, inFile: #file)
			}
		}
		super.setEnable(enables: param)
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(radioButtons: self)
	}
}

