/**
 * @file	KMSegue.swift
 * @brief	Define KMSegue class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

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
	private var mProcessManager:		CNProcessManager
	private var mContext:			KEContext
	private var mReturnValue:		CNNativeValue

	public init(mParentViewController parent: KMMultiComponentViewController, processManager procmgr: CNProcessManager, context ctxt: KEContext) {
		mParentViewController	= parent
		mProcessManager		= procmgr
		mContext		= ctxt
		mReturnValue		= .nullValue
	}

	public func enter(_ nameval: JSValue) -> JSValue {
		var result = false
		if nameval.isString {
			if let name = nameval.toString() {
				result = mParentViewController.pushViewController(byName: name)
			}
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
