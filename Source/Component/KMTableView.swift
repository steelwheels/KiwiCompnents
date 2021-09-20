/**
 * @file	KMTableView.swift
 * @brief	Define KMTableView class
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

public class KMTableView: KCTableView, AMBComponent
{
	public static let LoadItem		= "load"
	public static let PressedItem		= "pressed"
	public static let HasHeaderItem		= "hasHeader"
	public static let RowCountItem		= "rowCount"
	public static let ColumnCountItem	= "columnCount"
	public static let IsDirtyItem		= "isDirty"

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
		//self.isEditable = true
		self.isEnable = true

		/* Sync initial value: hasHeader */
		if let val = robj.boolValue(forProperty: KMTableView.HasHeaderItem) {
			CNExecuteInMainThread(doSync: false, execute: {
				self.hasHeader = val
			})
		} else {
			robj.setBoolValue(value: self.hasHeader, forProperty: KMTableView.HasHeaderItem)
		}

		/* allocate callback */
		self.cellClickedCallback = {
			(_ isdouble: Bool, _ col: String, _ row: Int) -> Void in
			if let pressed = robj.immediateValue(forProperty: KMTableView.PressedItem) {
				if let colval = JSValue(object: col, in: robj.context),
				   let rowval = JSValue(int32: Int32(row), in: robj.context) {
					CNExecuteInUserThread(level: .event, execute: {
						let args   = [robj, colval, rowval]
						pressed.call(withArguments: args)
					})
				}
			}
		}

		/* allocate status listner */
		robj.setBoolValue(value: false, forProperty: KMTableView.IsDirtyItem)
		robj.addScriptedPropertyName(name: KMTableView.IsDirtyItem)

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
			robj.setBoolValue(value: isdirty, forProperty: KMTableView.IsDirtyItem)
		}

		/* add load table method */
		let loadfunc: @convention(block) (_ tblval: JSValue) -> JSValue = {
			(_ tblval: JSValue) -> JSValue in
			self.callLoadMethod(tableValue: tblval, context: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: loadfunc, in: robj.context), forProperty: KMTableView.LoadItem)
		robj.addScriptedPropertyName(name: KMTableView.LoadItem)

		setupSizeInfo()
		return nil
	}

	private func callLoadMethod(tableValue tblval: JSValue, context ctxt: KEContext) -> JSValue {
		var result = false
		if tblval.isObject {
			if let tblobj = tblval.toObject() as? KLTableCore {
				let table = KCTableBridge(table: tblobj.core())
				CNExecuteInMainThread(doSync: false, execute: {
					() -> Void in
					self.load(table: table)
				})
				result = true
			} else if let dictobj = tblval.toDictionary() {
				var dict: Dictionary<String, CNValue> = [:]
				for (key, aval) in dictobj {
					if let keystr = key as? String, let val = CNValue.anyToValue(object: aval) {
						dict[keystr] = val
					}
				}
				if dict.count > 0 {
					let table = KCDictionaryTableBridge(dictionary: dict)
					CNExecuteInMainThread(doSync: false, execute: {
						() -> Void in
						self.load(table: table)
					})
					result = true
				}
			}
		}
		return JSValue(bool: result, in: ctxt)
	}

	private func setupSizeInfo() {
		let robj = reactObject
		robj.setInt32Value(value: Int32(self.numberOfRows),	forProperty: KMTableView.RowCountItem)
		robj.setInt32Value(value: Int32(self.numberOfColumns),	forProperty: KMTableView.ColumnCountItem)
	}

	open override func load(table tbl: KCTableInterface?) {
		super.load(table: tbl)
		setupSizeInfo()
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(tableView: self)
	}

	public func addChild(component comp: AMBComponent) {
		mConsole.error(string: "Not supported: addChild at \(#function) in \(#file)")
	}
}


