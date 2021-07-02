/**
 * @file	KMDataTableView.swift
 * @brief	Define KMDataTableView class
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

public class KMDataTableView: KCTableView, AMBComponent
{
	public static let ReloadItem		= "reload"
	public static let PressedItem		= "pressed"
	public static let EditableItem		= "editable"
	public static let HasHeaderItem		= "hasHeader"
	public static let RowCountItem		= "rowCount"
	public static let ColumnCountItem	= "columnCount"

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

		/* Sync initial value: editable */
		if let val = robj.boolValue(forProperty: KMDataTableView.EditableItem) {
			CNExecuteInMainThread(doSync: false, execute: {
				self.isEditable = val
			})
		} else {
			robj.setBoolValue(value: self.isEditable, forProperty: KMDataTableView.EditableItem)
		}

		/* Sync initial value: hasHeader */
		if let val = robj.boolValue(forProperty: KMDataTableView.HasHeaderItem) {
			CNExecuteInMainThread(doSync: false, execute: {
				self.hasHeader = val
			})
		} else {
			robj.setBoolValue(value: self.hasHeader, forProperty: KMDataTableView.HasHeaderItem)
		}

		/* allocate callback */
		self.cellPressedCallback = {
			(_ col: Int, _ row: Int) -> Void in
			if let pressed = robj.immediateValue(forProperty: KMDataTableView.PressedItem) {
				if let colval = JSValue(int32: Int32(col), in: robj.context),
				   let rowval = JSValue(int32: Int32(row), in: robj.context) {
					CNExecuteInUserThread(level: .event, execute: {
						let args   = [robj, colval, rowval]
						pressed.call(withArguments: args)
					})
				}
			}
		}

		/* add reload method */
		let reloadfunc: @convention(block) (_ tblval: JSValue) -> JSValue = {
			(_ tblval: JSValue) -> JSValue in
			var result = false
			if tblval.isObject {
				if let tblobj = tblval.toObject() as? KLValueTable {
					CNExecuteInMainThread(doSync: false, execute: {
						() -> Void in
						super.reloadTable(table: tblobj.core)
					})
					result = true
				}
			}
			return JSValue(bool: result, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: reloadfunc, in: robj.context), forProperty: KMDataTableView.ReloadItem)
		robj.addScriptedPropertyName(name: KMDataTableView.ReloadItem)

		setupSizeInfo()
		return nil
	}

	private func setupSizeInfo() {
		let robj = reactObject
		robj.setInt32Value(value: Int32(self.numberOfRows),	forProperty: KMDataTableView.RowCountItem)
		robj.setInt32Value(value: Int32(self.numberOfColumns),	forProperty: KMDataTableView.ColumnCountItem)
	}

	open override func reloadTable(table tbl: CNNativeTableInterface?) {
		super.reloadTable(table: tbl)
		setupSizeInfo()
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(dataTableView: self)
	}

	public func addChild(component comp: AMBComponent) {
		mConsole.error(string: "Not supported: addChild at \(#function) in \(#file)")
	}
}


