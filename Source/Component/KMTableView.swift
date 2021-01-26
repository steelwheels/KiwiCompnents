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
#if os(iOS)
import UIKit
#endif

public class KMTableView: KCTableView, AMBComponent
{
	public static let RowCountItem		= "rowCount"
	public static let ColumnCountItem	= "columnCount"
	public static let CellItem		= "cell"
	public static let MakeItem		= "make"
	public static let PressedItem		= "pressed"

	private var mReactObject:	AMBReactObject?
	private var mChildComponents:	Array<AMBComponent>
	private var mCellTable:		KMCellTable
	private var mColumnCount:	Int
	private var mRowCount:		Int
	private var mCellComponent:	AMBComponent?
	private var mMakeEvent:		JSValue?

	public var reactObject: AMBReactObject	{ get {
		if let robj = mReactObject {
			return robj
		} else {
			fatalError("No react object")
		}
	}}

	public var children: Array<AMBComponent> { get { return mChildComponents }}

	public init(){
		mReactObject		= nil
		mColumnCount		= 1
		mRowCount		= 1
		mCellTable		= KMCellTable()
		mChildComponents	= []
		mCellComponent		= nil
		mMakeEvent		= nil
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
		mCellComponent		= nil
		mMakeEvent		= nil
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

		/* Get cell */
		let cellcomp: AMBComponent
		if let cell = searchChild(byName: KMTableView.CellItem) {
			cellcomp = cell
		} else {
			cons.error(string: "[Error] Table does not have \"cell\" component\n")
			cellcomp = allocateDummyCellComponent(reactObject: robj, console: cons)
		}
		mCellComponent = cellcomp

		/* Allocate columns and rows and set default values */
		for i in 0..<mColumnCount {
			let colname = "\(i)"
			if mCellTable.addColumn(title: colname) {
				for j in 0..<mRowCount {
					/* Allocate */
					let cobj = AMBReactObject(frame: cellcomp.reactObject.frame, context: robj.context, processManager: robj.processManager, resource: robj.resource, environment: robj.environment)
					mCellTable.append(colmunName: colname, value: cobj)
					/* Copy values */
					for pname in cellcomp.reactObject.scriptedPropertyNames {
						if let pval = cellcomp.reactObject.immediateValue(forProperty: pname) {
							cobj.setImmediateValue(value: pval, forProperty: pname)
						}
					}
					/* Define cell properties */
					defineCellProperty(colmunName: colname, rowIndex: j, context: robj.context, console: cons)
				}
			} else {
				cons.print(string: "Failed to add new column")
			}
		}

		/* get make event */
		if let evtval = robj.immediateValue(forProperty: KMTableView.MakeItem) {
			mMakeEvent = evtval
		}

		/* initialize */
		for i in 0..<mColumnCount {
			if let col = mCellTable.column(index: i) {
				let rowcnt = col.numberOfRows
				for j in 0..<rowcnt {
					updateCell(colmunName: col.title, rowIndex: j, context: robj.context, console: cons)
				}
			}
		}

		/* allocae callback */
		self.cellPressedCallback = {
			(_ col: Int, _ row: Int) -> Void in
			if let pressed = robj.immediateValue(forProperty: KMTableView.PressedItem) {
				if let colval = JSValue(int32: Int32(col), in: robj.context),
				   let rowval = JSValue(int32: Int32(row), in: robj.context) {
					let args   = [robj, colval, rowval]
					pressed.call(withArguments: args)
				}
			}
		}

		/* Set database */
		super.cellTable = mCellTable
		return nil
	}

	private func allocateDummyCellComponent(reactObject robj: AMBReactObject,  console cons: CNConsole) -> AMBComponentObject {
		let frm  = AMBFrame(className: "Label", instanceName: "lab0")
		let cobj = AMBReactObject(frame: frm, context: robj.context, processManager: robj.processManager, resource: robj.resource, environment: robj.environment)
		cobj.setStringValue(value: "Undefined", forProperty: "text")
		let newcomp = AMBComponentObject()
		if let err = newcomp.setup(reactObject: cobj, console: cons) {
			cons.error(string: "[Error] \(err.description)")
			fatalError("Can not happen")
		} else {
			return newcomp
		}
	}

	private func updateCell(colmunName cname: String, rowIndex ridx: Int, context ctxt: KEContext, console cons: CNConsole) {
		if let makefunc = mMakeEvent, let cidx = mCellTable.columnIndex(name: cname) {
			if let robj = mCellTable.get(colmunName: cname, rowIndex: ridx) {
				if let cval = JSValue(int32: Int32(cidx), in: ctxt), let rval = JSValue(int32: Int32(ridx), in: ctxt){
					let args = [robj, cval, rval]
					makefunc.call(withArguments: args)
				} else {
					cons.error(string: "Can not happen at \(#function)")
				}
			}
		}
	}

	private func defineCellProperty(colmunName cname: String, rowIndex ridx: Int, context ctxt: KEContext, console cons: CNConsole) {
		let TEMPORARY_VARIABLE_NAME = "_amber_temp_cell_"
		if let robj = mCellTable.get(colmunName: cname, rowIndex: ridx) {
			for pname in robj.allPropertyNames {
				let varname = TEMPORARY_VARIABLE_NAME + "\(cname)_\(ridx)_\(pname)"
				ctxt.setObject(robj, forKeyedSubscript: varname as NSString)
				let script =   "Object.defineProperty(\(varname), '\(pname)',{ \n"
					     + "  get()    { return this.get(\"\(pname)\") ; }, \n"
					     + "  set(val) { return this.set(\"\(pname)\", val) ; }, \n"
					     + "}) ;\n"
				ctxt.evaluateScript(script)
				//NSLog("script = \(script)")
			}
		}
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(tableView: self)
	}

	public func addChild(component comp: AMBComponent) {
		mChildComponents.append(comp)
	}
}

public class KMCellColumn {
	public var 	title: 		String
	public var	values:		Array<AMBReactObject>

	public init(title str: String) {
		title	= str
		values	= []
	}

	public var numberOfRows: Int {
		get { return values.count }
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

	public func numberOfColumns() -> Int {
		return mColumns.count
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
		if let col = column(index: idx) {
			return col.title
		} else {
			return nil
		}
	}

	public func columnIndex(name nm: String) -> Int? {
		return mTitles[nm]
	}

	public func column(named name: String) -> KMCellColumn? {
		if let idx = mTitles[name] {
			return column(index: idx)
		} else {
			return nil
		}
	}

	public func column(index idx: Int) -> KMCellColumn? {
		if 0<=idx && idx<mColumns.count {
			return mColumns[idx]
		} else {
			return nil
		}
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
			return mColumns[idx].numberOfRows
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

	public func view(colmunIndex cidx: Int, rowIndex ridx: Int) -> KCView? {
		if 0<=cidx && cidx<mColumns.count {
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

	public func get(colmunName cname: String, rowIndex ridx: Int) -> AMBReactObject? {
		if let cidx = mTitles[cname] {
			let col = mColumns[cidx]
			if 0<=ridx && ridx<col.values.count {
				return col.values[ridx]
			}
		}
		return nil
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

