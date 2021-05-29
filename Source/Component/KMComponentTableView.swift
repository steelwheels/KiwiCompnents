/**
 * @file	KMComponentTableView.swift
 * @brief	Define KMComponentTableView class
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

public class KMComponentTableView: KCTableView, AMBComponent
{
	public static let RowCountItem		= "rowCount"
	public static let ColumnCountItem	= "columnCount"
	public static let CellItem		= "cell"
	public static let MakeItem		= "make"
	public static let PressedItem		= "pressed"

	private var mReactObject:	AMBReactObject?
	private var mChildComponents:	Array<AMBComponent>
	private var mConsole:		CNConsole?
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
		mConsole		= nil
		mChildComponents	= []
		mCellComponent		= nil
		mMakeEvent		= nil
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 480, height: 160)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#endif
		super.init(frame: frame)
	}

	@objc required dynamic init?(coder: NSCoder) {
		mReactObject		= nil
		mConsole		= nil
		mChildComponents	= []
		mCellComponent		= nil
		mMakeEvent		= nil
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject		= robj
		mConsole		= cons

		/* Get column and row numbers */
		var columnnum: Int = 1
		if let val = robj.int32Value(forProperty: KMComponentTableView.ColumnCountItem) {
			if val >= 1 {
				columnnum = Int(val)
			}
		} else {
			cons.error(string: "No column count property: \(KMComponentTableView.ColumnCountItem)")
		}
		var rownum: Int = 1
		if let val = robj.int32Value(forProperty: KMComponentTableView.RowCountItem) {
			if val >= 1 {
				rownum = Int(val)
			}
		} else {
			cons.error(string: "No row count property: \(KMComponentTableView.RowCountItem)")
		}

		/* Get cell */
		let cellcomp: AMBComponent
		if let cell = searchChild(byName: KMComponentTableView.CellItem) {
			cellcomp = cell
		} else {
			cons.error(string: "[Error] Table does not have \"cell\" component\n")
			cellcomp = allocateDummyCellComponent(reactObject: robj, console: cons)
		}
		mCellComponent = cellcomp

		/* Allocate columns and rows and set default values */
		let valtable = super.valueTable
		for cidx in 0..<columnnum {
			for ridx in 0..<rownum {
				/* Allocate */
				let cobj = AMBReactObject(frame: cellcomp.reactObject.frame, context: robj.context, processManager: robj.processManager, resource: robj.resource, environment: robj.environment)
				valtable.setValue(column: cidx, row: ridx, value: .objectValue(cobj))
				/* Copy values */
				for pname in cellcomp.reactObject.scriptedPropertyNames {
					if let pval = cellcomp.reactObject.immediateValue(forProperty: pname) {
						cobj.setImmediateValue(value: pval, forProperty: pname)
					}
				}
				/* Define cell properties */
				defineCellProperty(column: cidx, row: ridx, context: robj.context, console: cons)
			}
		}

		/* get make event */
		if let evtval = robj.immediateValue(forProperty: KMComponentTableView.MakeItem) {
			mMakeEvent = evtval
		}

		/* initialize */
		for cidx in 0..<columnnum{
			for ridx in 0..<rownum {
				updateCell(column: cidx, row: ridx, context: robj.context, console: cons)
			}
		}

		/* allocae callback */
		self.cellPressedCallback = {
			(_ col: Int, _ row: Int) -> Void in
			if let pressed = robj.immediateValue(forProperty: KMComponentTableView.PressedItem) {
				if let colval = JSValue(int32: Int32(col), in: robj.context),
				   let rowval = JSValue(int32: Int32(row), in: robj.context) {
					CNExecuteInUserThread(level: .event, execute: {
						let args   = [robj, colval, rowval]
						pressed.call(withArguments: args)
					})
				}
			}
		}

		/* Reload data */
		super.reloadTable()

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

	private func updateCell(column cidx: Int, row ridx: Int, context ctxt: KEContext, console cons: CNConsole) {
		if let makefunc = mMakeEvent {
			let valtable = super.valueTable
			switch valtable.value(column: cidx, row: ridx) {
			case .objectValue(let obj):
				if let robj = obj as? AMBReactObject {
					if let cval = JSValue(int32: Int32(cidx), in: ctxt), let rval = JSValue(int32: Int32(ridx), in: ctxt){
						CNExecuteInUserThread(level: .event, execute: {
							let args = [robj, cval, rval]
							makefunc.call(withArguments: args)
						})
					} else {
						cons.error(string: "Can not happen (1) at \(#function) in \(#file)")
					}
				} else {
					cons.error(string: "Can not happen (2) at \(#function) in \(#file)")
				}
			default:
				break
			}
		}
	}

	private func defineCellProperty(column cidx: Int, row ridx: Int, context ctxt: KEContext, console cons: CNConsole) {
		let TEMPORARY_VARIABLE_NAME = "_amber_temp_cell_"
		let valtable = super.valueTable

		let rval = valtable.value(column: cidx, row: ridx)
		switch rval {
		case .objectValue(let obj):
			if let robj = obj as? AMBReactObject {
				for pname in robj.allPropertyNames {
					let varname = TEMPORARY_VARIABLE_NAME + "\(cidx)_\(ridx)_\(pname)"
					ctxt.setObject(robj, forKeyedSubscript: varname as NSString)
					let script =   "Object.defineProperty(\(varname), '\(pname)',{ \n"
						     + "  get()    { return this.get(\"\(pname)\") ; }, \n"
						     + "  set(val) { return this.set(\"\(pname)\", val) ; }, \n"
						     + "}) ;\n"
					ctxt.evaluateScript(script)
					//NSLog("script = \(script)")
				}
			}
		default:
			break
		}
	}

	public override func valueToView(value val: CNNativeValue) -> KCView? {
		let result: KCView?
		switch val {
		case .objectValue(let obj):
			if let ambobj = obj as? AMBReactObject {
				result = objectToView(object: ambobj)
			} else {
				result = nil
			}
		default:
			result = nil
		}
		return result
	}

	private func objectToView(object obj: AMBReactObject) -> KCView? {
		guard let cons = mConsole else {
			NSLog("Can not happen at \(#function)")
			return nil
		}

		let result: KCView?
		let mapper = KMComponentMapper()
		switch mapper.map(object: obj, console: cons) {
		case .ok(let comp):
			if let view = comp as? KCView {
				result = view
			} else {
				result = nil
			}
		case .error(let err):
			cons.error(string: "[Error] \(err.description)")
			result = nil
		@unknown default:
			cons.error(string: "[Error] Unknown case")
			result = nil
		}
		return result
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(componentTableView: self)
	}

	public func addChild(component comp: AMBComponent) {
		mChildComponents.append(comp)
	}
}


