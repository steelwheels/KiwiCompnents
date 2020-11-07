/**
 * @file	KMViewState.swift
 * @brief	Define KMViewState class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiEngine
import CoconutData
import JavaScriptCore
import Foundation

@objc public protocol KMViewStateProtocol: JSExport
{
	var isActive: JSValue { get }
	var returnValue: JSValue { get }
}

@objc public class KMViewState: NSObject, KMViewStateProtocol
{
	private var mContext:		KEContext
	private var mViewController:	KMComponentViewController
	private var mReturnValue:	CNNativeValue

	public init(context ctxt: KEContext, viewController vcont: KMComponentViewController) {
		mContext	= ctxt
		mViewController	= vcont
		mReturnValue	= .nullValue
	}

	public var isActive: JSValue {
		get {
			return JSValue(bool: self.checkActive(), in: mContext)
		}
	}

	private func checkActive() -> Bool {
		var front: Bool = false
		CNExecuteInMainThread(doSync: true, execute: {
			() -> Void in
			front = self.mViewController.isInFront
		})
		return front
	}

	public func setReturnValue(value val: CNNativeValue) {
		mReturnValue = val
	}

	public var returnValue: JSValue {
		get {
			return mReturnValue.toJSValue(context: mContext)
		}
	}
}

