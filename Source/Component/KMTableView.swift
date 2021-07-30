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
	public static let ReloadItem		= "reload"
	public static let SaveItem		= "save"
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
			(_ isdouble: Bool, _ col: Int, _ row: Int) -> Void in
			if let pressed = robj.immediateValue(forProperty: KMTableView.PressedItem) {
				if let colval = JSValue(int32: Int32(col), in: robj.context),
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

		/* add reload method */
		let reloadfunc: @convention(block) (_ tblval: JSValue) -> JSValue = {
			(_ tblval: JSValue) -> JSValue in
			var result = false
			if tblval.isObject {
				var tblif: CNNativeTableInterface?
				if let tblobj = tblval.toObject() as? KLValueTable {
					tblif = tblobj.core
				} else if let tblobj = tblval.toObject() as? KLContactTable {
					tblif = tblobj.core
				} else {
					tblif = nil
				}
				if let core = tblif {
					CNExecuteInMainThread(doSync: false, execute: {
						() -> Void in
						self.reload(table: core)
					})
					result = true
				}
			}
			return JSValue(bool: result, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: reloadfunc, in: robj.context), forProperty: KMTableView.ReloadItem)
		robj.addScriptedPropertyName(name: KMTableView.ReloadItem)

		/* add save method */
		let savefunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			self.save()
			return JSValue(bool: true, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: savefunc, in: robj.context), forProperty: KMTableView.SaveItem)
		robj.addScriptedPropertyName(name: KMTableView.SaveItem)

		setupSizeInfo()
		return nil
	}

	private func setupSizeInfo() {
		let robj = reactObject
		robj.setInt32Value(value: Int32(self.numberOfRows),	forProperty: KMTableView.RowCountItem)
		robj.setInt32Value(value: Int32(self.numberOfColumns),	forProperty: KMTableView.ColumnCountItem)
	}

	open override func reload(table tbl: CNNativeTableInterface?) {
		super.reload(table: tbl)
		setupSizeInfo()
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(tableView: self)
	}

	public func addChild(component comp: AMBComponent) {
		mConsole.error(string: "Not supported: addChild at \(#function) in \(#file)")
	}
}


