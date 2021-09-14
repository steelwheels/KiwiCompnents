/**
 * @file	KMDictionaryView.swift
 * @brief	Define KMDictionaryView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Amber
import KiwiControls
import KiwiLibrary
import KiwiEngine
import CoconutData
import JavaScriptCore
import Foundation

public class KMDictionaryView: KCTableView, AMBComponent
{
	public static let LoadItem	= "load"
	public static let PressedItem	= "pressed"
	public static let ValueItem	= "value"
	public static let IsDirtyItem	= "isDirty"

	private var mReactObject:	AMBReactObject?
	private var mConsole:		CNConsole

	public var reactObject: AMBReactObject	{ get {
		if let robj = mReactObject {
			return robj
		} else {
			fatalError("No react object")
		}
	}}

	public var children: Array<AMBComponent> { get { return [] }}

	public init(){
		mReactObject		= nil
		mConsole		= CNFileConsole()
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 480, height: 160)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#endif
		super.init(frame: frame)
	}

	@objc required dynamic init?(coder: NSCoder) {
		mReactObject		= nil
		mConsole		= CNFileConsole()
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj
		mConsole	= cons

		/* allocate callback */
		self.cellClickedCallback = {
			(_ isdouble: Bool, _ col: Int, _ row: Int) -> Void in
			if let pressed = robj.immediateValue(forProperty: KMDictionaryView.PressedItem) {
				if let colval = JSValue(int32: Int32(col), in: robj.context),
				   let rowval = JSValue(int32: Int32(row), in: robj.context) {
					CNExecuteInUserThread(level: .event, execute: {
						let args   = [robj, colval, rowval]
						pressed.call(withArguments: args)
					})
				}
			}
		}

		robj.setBoolValue(value: false, forProperty: KMDictionaryView.IsDirtyItem)
		super.stateListner = {
			(_ state: DataState) -> Void in
			CNLog(logLevel: .detail, message: "Detect updated table state", atFunction: #function, inFile: #file)
			let isdirty: Bool
			switch state {
			case .clean:	isdirty = false
			case .dirty:	isdirty = true
			@unknown default:
				CNLog(logLevel: .error, message: "Unknown case", atFunction: #function, inFile: #file)
				isdirty = false
			}
			robj.setBoolValue(value: isdirty, forProperty: KMDictionaryView.IsDirtyItem)
		}

		/* add load table method */
		let loadfunc: @convention(block) (_ dictval: JSValue) -> JSValue = {
			(_ dictval: JSValue) -> JSValue in
			var result = false
			if dictval.isDictionary {
				if let dict = dictval.toDictionary() as? Dictionary<String, Any> {
					/* Update value property */
					robj.setImmediateValue(value: JSValue(object: dict, in: robj.context), forProperty: KMDictionaryView.ValueItem)
					/* Dictionary to table */
					let table = CNValueTable()

					let keys = dict.keys.sorted()
					for key in keys {
						if let val = dict[key] {
							let rec = CNValueRecord()
							let _ = rec.setValue(value: .stringValue(key), forField: "key")
							let _ = rec.setValue(value: self.anyToValue(data: val), forField: "value")
							table.append(record: rec)
						}
					}
					CNExecuteInMainThread(doSync: false, execute: {
						() -> Void in
						self.load(table: table)
					})
					result = true
				} else {
					CNLog(logLevel: .error, message: "Not dictionary (2)", atFunction: #function, inFile: #file)
				}
			} else {
				CNLog(logLevel: .error, message: "Not dictionary (1)", atFunction: #function, inFile: #file)
			}
			return JSValue(bool: result, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: loadfunc, in: robj.context), forProperty: KMDictionaryView.LoadItem)
		robj.addScriptedPropertyName(name: KMDictionaryView.LoadItem)

		/* Iniitialize value property */
		let empty: Dictionary<String, CNValue> = [:]
		robj.setImmediateValue(value: JSValue(object: empty, in: robj.context), forProperty: KMDictionaryView.ValueItem)
		robj.addScriptedPropertyName(name: KMDictionaryView.ValueItem)

		return nil
	}

	private func anyToValue(data dat: Any) -> CNValue {
		NSLog("anyToValue(\(dat))")
		if let res = CNValue.anyToValue(object: dat) {
			let str = res.toText().toStrings().joined(separator: "\n")
			NSLog(" -> \(str)")
			return res
		} else {
			NSLog(" -> NULL")
			return .nullValue
		}
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(dictionaryView: self)
	}

	public func addChild(component comp: AMBComponent) {
		mConsole.error(string: "Not supported: addChild at \(#function) in \(#file)")
	}
}

