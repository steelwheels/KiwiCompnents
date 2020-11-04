/**
 * @file	KMTextField.swift
 * @brief	Define KMTextField class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import KiwiControls
import KiwiEngine
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMTextField: KCTextField, AMBComponent
{
	public static let TextItem		= "text"

	private var mReactObject:	AMBReactObject?
	private var mContext:		KEContext?
	private var mEnvironment:	CNEnvironment?
	private var mChildComponents:	Array<AMBComponent>

	public var reactObject: AMBReactObject	{ get { getProperty(mReactObject) 	}}
	public var context: KEContext		{ get { getProperty(mContext) 		}}
	public var environment: CNEnvironment	{ get { getProperty(mEnvironment)	}}

	public var children: Array<AMBComponent> { get { return [] }}

	public init(){
		mReactObject		= nil
		mContext		= nil
		mEnvironment		= nil
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
		mContext		= nil
		mEnvironment		= nil
		mChildComponents	= []
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, context ctxt: KEContext, processManager pmgr: CNProcessManager, environment env: CNEnvironment) -> NSError? {
		mReactObject	= robj
		mContext	= ctxt
		mEnvironment	= env
		
		/* Sync initial value: text */
		if let val = robj.getStringProperty(forKey: KMTextField.TextItem) {
			super.text = val
		} else {
			robj.set(key: KMTextField.TextItem, stringValue: self.text)
		}
		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(textField: self)
	}

	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Unsupported method: addChild")
	}

	public func toText() -> CNTextSection {
		return reactObject.toText()
	}
}

