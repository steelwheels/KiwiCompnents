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
	public static let TableItem	= "table"
	public static let ReloadItem	= "reload"
	public static let PressedItem	= "pressed"

	private var mReactObject:	AMBReactObject?
	private var mTableData:		KMTableData?
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
		mTableData		= nil
		mConsole		= CNFileConsole()
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#endif
		super.init(frame: frame)
	}

	@objc required dynamic init?(coder: NSCoder) {
		mReactObject		= nil
		mTableData		= nil
		mConsole		= CNFileConsole()
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj
		mConsole	= cons

		let dtable = KMTableData(console: cons)
		mTableData = dtable

		/* If the value table is empty, set 1 cell */
		if dtable.rowCount == 0 {
			dtable.setValue(column: 0, row: 0, value: .nullValue)
		}

		/* Allocate value table */
		let valtable = KLValueTable(table: dtable, context: robj.context)
		/* Define property */
		robj.setImmediateValue(value: JSValue(object: valtable, in: robj.context),
				       forProperty: KMDataTableView.TableItem)
		robj.addScriptedPropertyName(name: KMDataTableView.TableItem)

		/* allocae callback */
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
		let reloadfunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			self.reload()
			return JSValue(bool: true, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: reloadfunc, in: robj.context), forProperty: KMDataTableView.ReloadItem)
		robj.addScriptedPropertyName(name: KMDataTableView.ReloadItem)

		/* Set database and reload context */
		super.tableDelegate = dtable

		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(dataTableView: self)
	}

	public func addChild(component comp: AMBComponent) {
		mConsole.error(string: "Not supported: addChild at \(#function) in \(#file)")
	}
}


