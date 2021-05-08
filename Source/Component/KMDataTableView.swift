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
	public static let PressedItem	= "pressed"

	private var mReactObject:	AMBReactObject?
	private var mConsole:		CNConsole
	private var mCellTable:		KCCellTable
	private var mNativeTable:	CNNativeValueTable
	private var mValueTable:	KLValueTable?

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
		mCellTable		= KCCellTable()
		mNativeTable		= CNNativeValueTable()
		mValueTable		= nil
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#endif
		super.init(frame: frame)
	}

	@objc required dynamic init?(coder: NSCoder) {
		mReactObject		= nil
		mConsole		= CNFileConsole()
		mCellTable		= KCCellTable()
		mNativeTable		= CNNativeValueTable()
		mValueTable		= nil
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj
		mConsole	= cons

		/* If the value table is empty, set 1 cell */
		if mNativeTable.columnCount == 0 {
			NSLog("[KMDataTableView: Fill dummy cell into empty native value table")
			let newcol = CNNativeValueColumn()
			newcol.appendValue(value: .nullValue)
			mNativeTable.appendColumn(column: newcol)
		}

		/* Allocate value table */
		let valtable = KLValueTable(nativeTable: mNativeTable, context: robj.context)
		mValueTable = valtable

		/* Define property */
		robj.setImmediateValue(value: JSValue(object: valtable, in: robj.context),
				       forProperty: KMDataTableView.TableItem)
		robj.addScriptedPropertyName(name: KMDataTableView.TableItem)

		/* Allocate columns and rows and set default values */
		setupCells(valueTable: mNativeTable)

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

		/* Set database */
		super.cellTable = mCellTable
		return nil
	}

	private func setupCells(valueTable valtable: CNNativeValueTable){
		var colid = 0
		valtable.forEach({
			(ncol: CNNativeValueColumn) -> Void in
			/* Decide column title */
			let title: String
			if let t = ncol.title {
				title = t
			} else {
				title = "\(colid)"
				ncol.title = title
			}
			/* Allocate new column */
			if mCellTable.addColumn(title: title) {
				ncol.forEach({
					(val: CNNativeValue) -> Void in
					mCellTable.append(colmunName: title, value: val)
				})
			}
			/* update column id */
			colid += 1
		})
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(dataTableView: self)
	}

	public func addChild(component comp: AMBComponent) {
		NSLog("Not supported: addChild at \(#file)")
	}
}

public class KMDataColumn {
	public var 	title: 		String
	public var	values:		Array<CNNativeValue>

	public init(title str: String) {
		title	= str
		values	= []
	}

	public var numberOfRows: Int {
		get { return values.count }
	}
}

