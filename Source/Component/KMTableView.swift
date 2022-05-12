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
import CoconutDatabase
import JavaScriptCore
import Foundation

public class KMTableView: KCTableView, AMBComponent
{
	public typealias FieldName = KCTableViewCore.FieldName

	private static let PressedItem			= "pressed"
	private static let FieldNamesItem		= "fieldNames"
	private static let HasHeaderItem		= "hasHeader"
	private static let IsEditableItem		= "isEditable"
	private static let DidSelectedItem		= "didSelected"
	private static let DataTableItem		= "dataTable"
	private static let FilterItem			= "filter"
	private static let RowCountItem			= "rowCount"
	private static let VisibleRowCountItem		= "visibleRowCount"
	private static let SelectedRecordsItem		= "selectedRecords"
	private static let RemoveSelectedRowsItem	= "removeSelectedRows"
	private static let ReloadItem			= "reload"
	private static let IsDirtyItem			= "isDirty"
	private static let VirtualFieldsItem		= "virtualFields"

	private var mReactObject:	AMBReactObject?
	private var mChildComponents:	Array<AMBComponent>
	private var mConsole:		CNConsole

	public var reactObject: AMBReactObject	{ get {
		if let robj = mReactObject {
			return robj
		} else {
			fatalError("No react object")
		}
	}}

	public var children: Array<AMBComponent> { get {
		return mChildComponents
	}}

	public func addChild(component comp: AMBComponent) {
		mChildComponents.append(comp)
	}

	public init(){
		mReactObject		= nil
		mChildComponents	= []
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
		mChildComponents	= []
		mConsole		= CNFileConsole()
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject		= robj
		mConsole		= cons
		self.isEnable 		= true

		/* Sync initial value: hasHeader */
		addScriptedProperty(object: robj, forProperty: KMTableView.HasHeaderItem)
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
		addScriptedProperty(object: robj, forProperty: KMTableView.IsDirtyItem)
		robj.setBoolValue(value: false, forProperty: KMTableView.IsDirtyItem)

		/* Add fieldNames property */
		addScriptedProperty(object: robj, forProperty: KMTableView.FieldNamesItem)
		if let fvals = robj.arrayValue(forProperty: KMTableView.FieldNamesItem) {
			var result: Array<FieldName> = []
			for elm in fvals {
				if let dict = elm as? Dictionary<String, String> {
					if let field = dict["field"], let title = dict["title"] {
						let fname = FieldName(field: field, title: title)
						result.append(fname)
					} else {
						CNLog(logLevel: .error, message: "Invalid active field name: field and title properties are required")
					}
				} else {
					CNLog(logLevel: .error, message: "Invalid active field name: dictionary data is required but \"\(elm)\" is given")
				}
			}
			if result.count > 0 {
				self.fieldNames = result
			}
		} else {
			robj.setArrayValue(value: [], forProperty: KMTableView.FieldNamesItem)
		}

		/* rowCount */
		addScriptedProperty(object: robj, forProperty: KMTableView.RowCountItem)
		robj.setInt32Value(value: Int32(self.numberOfRows),	forProperty: KMTableView.RowCountItem)

		/* isEditable */
		addScriptedProperty(object: robj, forProperty: KMTableView.IsEditableItem)
		if let val = robj.boolValue(forProperty: KMTableView.IsEditableItem) {
			self.isEditable = val
		} else {
			robj.setBoolValue(value: self.isEditable, forProperty: KMTableView.IsEditableItem)
		}

		/* Add didSelected properties */
		addScriptedProperty(object: robj, forProperty: KMTableView.DidSelectedItem)
		if let val = robj.boolValue(forProperty: KMTableView.DidSelectedItem) {
			robj.setBoolValue(value: val, forProperty: KMTableView.DidSelectedItem)
		} else {
			robj.setBoolValue(value: false, forProperty: KMTableView.DidSelectedItem)
		}
		super.didSelectedCallback = {
			(_ selected: Bool) -> Void in
			robj.setBoolValue(value: selected, forProperty: KMTableView.DidSelectedItem)
		}

		/* Add visibleRowCount property */
		addScriptedProperty(object: robj, forProperty: KMTableView.VisibleRowCountItem)
		if let val = robj.int32Value(forProperty: KMTableView.VisibleRowCountItem) {
			self.minimumVisibleRowCount = Int(val)
		} else {
			robj.setInt32Value(value: Int32(self.minimumVisibleRowCount), forProperty: KMTableView.VisibleRowCountItem)
		}

		/* selectedRows method */
		addScriptedProperty(object: robj, forProperty: KMTableView.SelectedRecordsItem)
		let selrecsfunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			var recs: Array<KLRecord> = []
			CNExecuteInMainThread(doSync: true, execute: {
				() -> Void in
				for rec in super.selectedRecords() {
					recs.append(KLRecord(record: rec, context: robj.context))
				}
			})
			if let recobj = JSValue(object: recs, in: robj.context) {
				return recobj
			} else {
				CNLog(logLevel: .error, message: "Failed to allocate array of records", atFunction: #function, inFile: #file)
				return JSValue(newArrayIn: robj.context)
			}
		}
		robj.setImmediateValue(value: JSValue(object: selrecsfunc, in: robj.context), forProperty: KMTableView.SelectedRecordsItem)

		/* remove selected row method */
		addScriptedProperty(object: robj, forProperty: KMTableView.RemoveSelectedRowsItem)
		let rmrowsfunc: @convention(block) () -> JSValue = {
			() -> JSValue in
			CNExecuteInMainThread(doSync: false, execute: {
				super.removeSelectedRows()
			})
			return JSValue(bool: true, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: rmrowsfunc, in: robj.context), forProperty: KMTableView.RemoveSelectedRowsItem)

		/* table property */
		addScriptedProperty(object: robj, forProperty: KMTableView.DataTableItem)
		if let val = robj.objectValue(forProperty: KMTableView.DataTableItem) {
			if let tbl = val as? KLTableCore {
				CNExecuteInMainThread(doSync: false, execute: {
					() -> Void in self.dataTable = tbl.core()
				})
			}
		} else {
			let obj = KLValueTable(table: self.dataTable, context: robj.context)
			robj.setObjectValue(value: obj, forProperty: KMTableView.DataTableItem)
		}
		robj.addObserver(forProperty: KMTableView.DataTableItem, callback: {
			(_ param: Any) -> Void in
			if let obj = robj.objectValue(forProperty: KMTableView.DataTableItem) {
				if let tbl = obj as? KLTableCore {
					CNExecuteInMainThread(doSync: false, execute: {
						() -> Void in self.dataTable = tbl.core()
					})
				}
			}
		})

		/* filter property */
		addScriptedProperty(object: robj, forProperty: KMTableView.FilterItem)
		if let _ = robj.immediateValue(forProperty: KMTableView.FilterItem) {
			/* already set */
		} else {
			robj.setImmediateValue(value: JSValue(nullIn: robj.context), forProperty: KMTableView.FilterItem)
		}
		self.filterFunction = {
			(_ rec: CNRecord) -> Bool in
			var result = true
			if let val = robj.immediateValue(forProperty: KMTableView.FilterItem) {
				if !val.isNull {
					let recobj = KLRecord(record: rec, context: robj.context)
					/* Call event function: event(self, record) */
					if let retval = val.call(withArguments: [robj, recobj]) {
						if retval.isBoolean {
							result = retval.toBool()
						} else {
							CNLog(logLevel: .error, message: "Unexpected return value of removeMapping method", atFunction: #function, inFile: #file)
						}
					}
				}
			}
			return result
		}

		/* virtualFields */
		addScriptedProperty(object: robj, forProperty: KMTableView.VirtualFieldsItem)
		if let ccomp = self.searchChild(byName: KMTableView.VirtualFieldsItem) {
			let cobj   = ccomp.reactObject
			let cframe = cobj.frame
			for cmemb in cframe.members {
				switch cmemb.value.type {
				case .procedureFunction:
					if let funcval = cobj.immediateValue(forProperty: cmemb.identifier) {
						super.addVirtualField(name: cmemb.identifier, callbackFunction: {
							(_ rec: CNRecord) -> CNValue in
							let recobj = KLRecord(record: rec, context: robj.context)
							if let retval = funcval.call(withArguments: [recobj]) {
								return retval.toNativeValue()
							} else {
								return .nullValue
							}
						})
					} else {
						CNLog(logLevel: .error, message: "No procedural function name: \(cmemb.identifier)", atFunction: #function, inFile: #file)
					}
				default:
					break
				}
			}
		}

		/* reload method */
		addScriptedProperty(object: robj, forProperty: KMTableView.ReloadItem)
		let reloadfunc: @convention(block) () -> JSValue = {
			() -> JSValue  in
			CNExecuteInMainThread(doSync: false, execute: {
				() -> Void in super.reload()
			})
			return JSValue(bool: true, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: reloadfunc, in: robj.context), forProperty: KMTableView.ReloadItem)

		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(tableView: self)
	}
}


