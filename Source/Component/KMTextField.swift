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
	private var mChildComponents:	Array<AMBComponent>

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
		mChildComponents	= []
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject) -> NSError? {
		mReactObject	= robj
		
		/* Sync initial value: text */
		if let val = robj.stringValue(forProperty: KMTextField.TextItem) {
			super.text = val
		} else {
			robj.setStringValue(string: self.text, forProperty: KMTextField.TextItem)
		}
		return nil
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(textField: self)
	}

	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Unsupported method: addChild")
	}
}

