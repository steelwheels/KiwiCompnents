/**
 * @file	KMCollectionView.swift
 * @brief	Define KMCollectionView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation
import KiwiControls
import Amber
import KiwiEngine
import KiwiLibrary
import JavaScriptCore
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMCollectionView: KCCollectionView, AMBComponent
{
	static let 	SectionCountItem	= "sectionCount"
	static let	ItemCountItem		= "itemCount"
	static let 	IsSelectableItem	= "isSelectable"
	static let	SelectedItem		= "selected"
	static let 	StoreItem		= "store"

	private var mReactObject:	AMBReactObject?

	public var reactObject: AMBReactObject	{ get {
		if let robj = mReactObject {
			return robj
		} else {
			fatalError("No react object")
		}
	}}

	public init() {
		mReactObject = nil
		let frame = CGRect(x: 0.0, y: 0.0, width: 188, height: 21)
		super.init(frame: frame)
	}

	@objc required dynamic init?(coder: NSCoder) {
		mReactObject = nil
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj

		/* isSelectable */
		addScriptedProperty(object: robj, forProperty: KMCollectionView.IsSelectableItem)
		if let val = robj.boolValue(forProperty: KMCollectionView.IsSelectableItem) {
			self.isSelectable = val
		} else {
			robj.setBoolValue(value: self.isSelectable, forProperty: KMCollectionView.IsSelectableItem)
		}

		/* sectionCount (read only) */
		addScriptedProperty(object: robj, forProperty: KMCollectionView.SectionCountItem)
		robj.setInt32Value(value: 0, forProperty: KMCollectionView.SectionCountItem)

		/* itemCount (method) */
		addScriptedProperty(object: robj, forProperty: KMCollectionView.ItemCountItem)
		let countfunc: @convention(block) (_ idx: JSValue) -> JSValue = {
			(_ idx: JSValue) -> JSValue in
			let result: JSValue
			if let num = self.itemCount(index: idx) {
				result = JSValue(int32: Int32(num), in: robj.context)
			} else {
				result = JSValue(nullIn: robj.context)
			}
			return result
		}
		robj.setImmediateValue(value: JSValue(object: countfunc, in: robj.context), forProperty: KMCollectionView.ItemCountItem)

		/* store (method) */
		addScriptedProperty(object: robj, forProperty: KMCollectionView.StoreItem)
		let storefunc: @convention(block) (_ value: JSValue) -> JSValue = {
			(_ value: JSValue)  in
			let result: Bool
			if let col = self.valueToCollection(value: value) {
				super.store(data: col)
				result = true
			} else {
				result = false
			}
			return JSValue(bool: result, in: robj.context)
		}
		robj.setImmediateValue(value: JSValue(object: storefunc, in: robj.context), forProperty: KMCollectionView.StoreItem)

		/* selected (callback) */
		self.set(selectionCallback: {
			(_ section: Int, _ item: Int) -> Void in
			if let evtval = robj.immediateValue(forProperty: KMCollectionView.SelectedItem) {
				if let secval  = JSValue(int32: Int32(section), in: robj.context),
				   let itemval = JSValue(int32: Int32(item),    in: robj.context) {
					CNExecuteInUserThread(level: .event, execute: {
						evtval.call(withArguments: [robj, secval, itemval])	// insert self
					})
				} else {
					CNLog(logLevel: .error, message: "Failed to generate parameter",
					      atFunction: #function, inFile: #file)
				}
			}
		})

		return nil
	}

	private func store(value val: JSValue) {
		if val.isObject {
			if let colobj = val.toObject() as? KLCollection {
				let core = colobj.core
				super.store(data: core)
				/* Update sectionCount */
				reactObject.setInt32Value(value: Int32(core.sectionCount), forProperty: KMCollectionView.SectionCountItem)
			}
		}
	}

	public var children: Array<AMBComponent>  { get { return [] }}
	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Can not add child components to Button component", atFunction: #function, inFile: #file)
	}

	private func itemCount(index idx: JSValue) -> Int? {
		if idx.isNumber {
			let idxval = Int(idx.toInt32())
			return super.numberOfItems(inSection: idxval)
		} else {
			return nil
		}
	}

	private func valueToCollection(value val: JSValue) -> CNCollection? {
		if val.isObject {
			let obj = val.toObject()
			if let col = obj as? KLCollection {
				return col.core
			}
		}
		CNLog(logLevel: .error, message: "Failed to convert parameter to collection", atFunction: #function, inFile: #file)
		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(collectionView: self)
	}
}

