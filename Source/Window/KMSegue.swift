/**
 * @file	KMSegue.swift
 * @brief	Define KMSegue class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiControls
import KiwiLibrary
import KiwiEngine
import CoconutData
import JavaScriptCore
import Foundation

public protocol KMSegueProtocol: JSExport
{
	func enter(_ scrfile: JSValue) -> JSValue
	func leave(_ retval: JSValue)
}

@objc public class KMSegue: NSObject, KMSegueProtocol
{
	private var mParentViewController:	KMMultiComponentViewController
	private var mContext:			KEContext
	private var mReturnValue:		CNNativeValue

	public init(parentViewController parent: KMMultiComponentViewController, context ctxt: KEContext) {
		mParentViewController	= parent
		mContext		= ctxt
		mReturnValue		= .nullValue
	}

	public func enter(_ viewval: JSValue) -> JSValue {
		var result: Bool
		if viewval.isString {
			let viewname = viewval.toString() as String
			mParentViewController.pushViewController(viewName: viewname)
			result = true
		} else {
			result = false
		}
		return JSValue(bool: result, in: mContext)
	}

	public func leave(_ retval: JSValue) {
		mReturnValue = retval.toNativeValue()
		if mParentViewController.popViewController() {
			CNLog(logLevel: .error, message: "Failed to pop view at \(#file)")
		}
	}

	private func valueToURL(_ val: JSValue) -> URL? {
		if val.isURL {
			return val.toURL()
		} else if val.isString {
			if let url = URL(string: val.toString()) {
				return url
			}
		}
		return nil
	}
}
