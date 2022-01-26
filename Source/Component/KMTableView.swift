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
	public typealias ActiveFieldName = KCTableViewCore.ActiveFieldName

	public static let StoreItem		= "store"
	public static let PressedItem		= "pressed"
	public static let FieldNamesItem	= "fieldNames"
	public static let HasHeaderItem		= "hasHeader"
	public static let IsSelectableItem	= "isSelectable"
	public static let DidSelectedItem	= "didSelected"
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
		let storefunc: @convention(block) (_ tblval: JSValue) -> JSValue = {
			(_ tblval: JSValue) -> JSValue in
			NSLog("store table")
			let retval = self.callStoreMethod(tableValue: tblval, context: robj.context)
			return retval
		}
		robj.setImmediateValue(value: JSValue(object: storefunc, in: robj.context), forProperty: KMTableView.StoreItem)
		robj.addScriptedPropertyName(name: KMTableView.StoreItem)

		/* Add fieldNames property */
		if let fvals = robj.arrayValue(forProperty: KMTableView.FieldNamesItem) {
			var result: Array<ActiveFieldName> = []
			for elm in fvals {
				if let dict = elm as? Dictionary<String, String> {
					if let field = dict["field"], let title = dict["title"] {
						let fname = ActiveFieldName(field: field, title: title)
						result.append(fname)
					} else {
						CNLog(logLevel: .error, message: "Invalid active field name: field and title properties are required")
					}
				} else {
					CNLog(logLevel: .error, message: "Invalid active field name: dictionary data is required")
				}
			}
			if result.count > 0 {
				self.activeFieldNames = result
			}
		} else {
			robj.setArrayValue(value: [], forProperty: KMTableView.FieldNamesItem)
			robj.addScriptedPropertyName(name: KMTableView.FieldNamesItem)
		}

		/* Add row/column count properties */
		if robj.int32Value(forProperty: KMTableView.RowCountItem) == nil {
			robj.addScriptedPropertyName(name: KMTableView.RowCountItem)
		}
		if robj.int32Value(forProperty: KMTableView.ColumnCountItem) == nil {
			robj.addScriptedPropertyName(name: KMTableView.ColumnCountItem)
		}

		/* Add isSelectable properties */
		if let val = robj.boolValue(forProperty: KMTableView.IsSelectableItem) {
			self.isSelectable = val
		} else {
			robj.setBoolValue(value: self.isSelectable, forProperty: KMTableView.IsSelectableItem)
			robj.addScriptedPropertyName(name: KMTableView.IsSelectableItem)
		}

		/* Add didSelected properties */
		if let val = robj.boolValue(forProperty: KMTableView.DidSelectedItem) {
			robj.setBoolValue(value: val, forProperty: KMTableView.DidSelectedItem)
		} else {
			robj.setBoolValue(value: false, forProperty: KMTableView.DidSelectedItem)
			robj.addScriptedPropertyName(name: KMTableView.DidSelectedItem)
		}
		super.didSelectedCallback = {
			(_ selected: Bool) -> Void in
			robj.setBoolValue(value: selected, forProperty: KMTableView.DidSelectedItem)
		}

		setupSizeInfo()
		return nil
	}

	private func callStoreMethod(tableValue tblval: JSValue, context ctxt: KEContext) -> JSValue {
		var result = false
		if let vtable = tblval.toObject() as? KLValueTable {
			if let table = vtable.core() as? CNValueTable {
				updateContents(valueTable: table)
				result = true
			} else {
				CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
			}
		} else if let vtable = tblval.toObject() as? KLTableCore {
			if let table = vtable.core() as? CNValueTable {
				updateContents(valueTable: table)
				result = true
			} else {
				CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
			}
		} else if let dictobj = tblval.toDictionary() {
			var dict: Dictionary<String, CNValue> = [:]
			for (key, aval) in dictobj {
				if let keystr = key as? String, let val = CNValue.anyToValue(object: aval) {
					dict[keystr] = val
				} else {
					CNLog(logLevel: .error, message: "Unexpected value type", atFunction: #function, inFile: #file)
				}
			}
			updateContents(dictionary: dict)
			result = true
		} else {
			CNLog(logLevel: .error, message: "Unexpected input type (2)", atFunction: #function, inFile: #file)
		}
		return JSValue(bool: result, in: ctxt)
	}

	private func updateContents(valueTable vtable: CNValueTable) {
		CNExecuteInMainThread(doSync: false, execute: {
			() -> Void in
			self.store(table: vtable)
			self.requireDisplay()
		})
	}

	private func updateContents(dictionary dict: Dictionary<String, CNValue>) {
		CNExecuteInMainThread(doSync: false, execute: {
			() -> Void in
			self.store(dictionary: dict)
			self.requireDisplay()
		})
	}

	private func setupSizeInfo() {
		let robj = reactObject
		robj.setInt32Value(value: Int32(self.numberOfRows),	forProperty: KMTableView.RowCountItem)
		robj.setInt32Value(value: Int32(self.numberOfColumns),	forProperty: KMTableView.ColumnCountItem)
	}

	open override func store(table tbl: CNTable?){
		super.store(table: tbl)
		setupSizeInfo()
	}

	open override func store(dictionary dict: Dictionary<String, CNValue>?){
		super.store(dictionary: dict)
		setupSizeInfo()
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(tableView: self)
	}

	public func addChild(component comp: AMBComponent) {
		mConsole.error(string: "Not supported: addChild at \(#function) in \(#file)")
	}
}


