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
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMTableView: KCTableView, AMBComponent
{
	public static let RowCountItem		= "rowCount"
	public static let ColumnCountItem	= "columnCount"

	private var mReactObject:	AMBReactObject?
	private var mChildComponents:	Array<AMBComponent>
	private var mCellTable:		KMCellTable
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
		mColumnCount		= 1
		mRowCount		= 1
		mCellTable		= KMCellTable()
		mChildComponents	= []
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#endif
		super.init(frame: frame)
	}

	@objc required dynamic init?(coder: NSCoder) {
		mReactObject		= nil
		mColumnCount		= 1
		mRowCount		= 1
		mCellTable		= KMCellTable()
		mChildComponents	= []
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject		= robj
		mCellTable.console	= cons

		/* Get column and row numbers */
		if let val = robj.int32Value(forProperty: KMTableView.ColumnCountItem) {
			if val >= 1 {
				mColumnCount = Int(val)
			}
		} else {
			cons.error(string: "No column count property: \(KMTableView.ColumnCountItem)")
			mColumnCount = 1
		}
		if let val = robj.int32Value(forProperty: KMTableView.RowCountItem) {
			if val >= 1 {
				mRowCount = Int(val)
			}
		} else {
			cons.error(string: "No row count property: \(KMTableView.RowCountItem)")
			mRowCount = 1
		}

		/* Allocate columns */
		for i in 0..<mColumnCount {
			let colname = "col\(i)"
			if mCellTable.addColumn(title: colname) {
				for j in 0..<mRowCount {
					let frm  = AMBFrame(className: "Label", instanceName: "lab0")
					let cobj = AMBReactObject(frame: frm, context: robj.context, processManager: robj.processManager, resource: robj.resource, environment: robj.environment)
					cobj.setStringValue(value: "\(i)x\(j)", forProperty: "text")
					mCellTable.append(colmunName: colname, value: cobj)
					NSLog("FRAME= \(cobj.description)")
				}
			} else {
				NSLog("Failed to add new column")
			}
		}
		NSLog("end of setup table")

		/* allocae callback */
		self.cellPressedCallback = {
			(_ column: String, _ row: Int) -> Void in
			NSLog("pressed: \(column) \(row)")
		}

		/* Set database */
		super.cellTable = mCellTable
		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(tableView: self)
	}

	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Unsupported method: addChild")
	}
}

public class KMCellColumn {
	public var 	title: 		String
	public var	values:		Array<AMBReactObject>

	public init(title str: String) {
		title	= str
		values	= []
	}
}

public class KMCellTable: KCCellTableInterface
{
	private var mConsole:	CNConsole
	private var mTitles:	Dictionary<String, Int>		// <Title, Index>
	private var mColumns:	Array<KMCellColumn>

	public init() {
		mConsole	= CNFileConsole()
		mTitles		= [:]
		mColumns	= []
	}

	public var console: CNConsole {
		get		{ return mConsole }
		set(newcons)	{ mConsole = newcons}
	}

	public func addColumn(title ttl: String) -> Bool {
		if mTitles[ttl] == nil {
			let newcol   = KMCellColumn(title: ttl)
			mTitles[ttl] = mColumns.count
			mColumns.append(newcol)
			return true
		} else {
			mConsole.error(string: "Already exist: \(ttl) at \(#function)")
			return false
		}
	}

	public func columnTitle(index idx: Int) -> String? {
		if 0<=idx && idx<mColumns.count {
			return mColumns[idx].title
		} else {
			return nil
		}
	}

	public func numberOfColumns() -> Int {
		return mColumns.count
	}

	public func numberOfRows(columnIndex idx: Int) -> Int? {
		if 0<=idx && idx<mColumns.count {
			return mColumns[idx].values.count
		} else {
			return nil
		}
	}

	public func numberOfRows(columnName name: String) -> Int? {
		if let idx = mTitles[name] {
			return mColumns[idx].values.count
		} else {
			return nil
		}
	}

	public func maxNumberOfRows() -> Int {
		var result = 0
		for col in mColumns {
			result = max(result, col.values.count)
		}
		return result
	}

	public func view(colmunName cname: String, rowIndex ridx: Int) -> KCView? {
		if let cidx = mTitles[cname] {
			let col = mColumns[cidx]
			if 0<=ridx && ridx<col.values.count {
				let val = col.values[ridx]
				return valueToView(value: val)
			}
		}
		return nil
	}

	public func set(colmunName cname: String, rowIndex ridx: Int, data dat: Any?) {
		if let val = dat as? AMBReactObject {
			set(colmunName: cname, rowIndex: ridx, value: val)
		} else {
			mConsole.error(string: "Failed to set at \(#function)")
		}
	}

	public func set(colmunName cname: String, rowIndex ridx: Int, value val: AMBReactObject) {
		if let cidx = mTitles[cname] {
			let col = mColumns[cidx]
			if 0<=ridx && ridx<col.values.count {
				col.values[ridx] = val
				return
			}
		}
		mConsole.error(string: "Failed to set at \(#function)")
	}

	public func append(colmunName cname: String, data dat: Any?) {
		if let val = dat as? AMBReactObject {
			append(colmunName: cname, value: val)
		} else {
			mConsole.error(string: "Failed to append at \(#function)")
		}
	}

	public func append(colmunName cname: String, value val: AMBReactObject) {
		if let cidx = mTitles[cname] {
			let col = mColumns[cidx]
			col.values.append(val)
		} else {
			mConsole.error(string: "Failed to append at \(#function)")
		}
	}

	private func valueToView(value val: AMBReactObject) -> KCView? {
		let mapper = KMComponentMapper()
		switch mapper.map(object: val, console: mConsole) {
		case .ok(let comp):
			if let view = comp as? KCView {
				return view
			} else {
				mConsole.error(string: "Not view object")
			}
		case .error(let err):
			mConsole.error(string: "[Error] \(err.description)")
		@unknown default:
			mConsole.error(string: "[Error] Unknown case")
		}
		return nil
	}
}

