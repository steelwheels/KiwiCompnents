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
	public static let RowCountItem		= "rowCount"
	public static let ColumnCountItem	= "columnCount"
	public static let PressedItem		= "pressed"

	private var mReactObject:	AMBReactObject?
	private var mConsole:		CNConsole
	private var mCellTable:		KCCellTable
	private var mColumnCount:	Int
	private var mRowCount:		Int

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
		mColumnCount		= 1
		mRowCount		= 1
		mCellTable		= KCCellTable()
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
		mColumnCount		= 1
		mRowCount		= 1
		mCellTable		= KCCellTable()
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj
		mConsole	= cons

		/* Get column and row numbers */
		if let val = robj.int32Value(forProperty: KMDataTableView.ColumnCountItem) {
			if val >= 1 {
				mColumnCount = Int(val)
			}
		} else {
			cons.error(string: "No column count property: \(KMDataTableView.ColumnCountItem)")
			mColumnCount = 1
		}
		if let val = robj.int32Value(forProperty: KMDataTableView.RowCountItem) {
			if val >= 1 {
				mRowCount = Int(val)
			}
		} else {
			cons.error(string: "No row count property: \(KMDataTableView.RowCountItem)")
			mRowCount = 1
		}

		/* Allocate columns and rows and set default values */
		for i in 0..<mColumnCount {
			let colname = "\(i)"
			if mCellTable.addColumn(title: colname) {
				for _ in 0..<mRowCount {
					/* Allocate */
					let nullvalue: CNNativeValue = .nullValue
					mCellTable.append(colmunName: colname, value: nullvalue)
				}
			} else {
				cons.print(string: "Failed to add new column")
			}
		}

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

