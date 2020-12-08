/**
 * @file	KMViewState.swift
 * @brief	Define KMViewState class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiEngine
import KiwiControls
import CoconutData
import JavaScriptCore
import Foundation

@objc public protocol KMViewStateProtocol: JSExport
{
	var isForeground: JSValue { get }
	var returnValue:  JSValue { get }
}

@objc public class KMViewState: NSObject, KMViewStateProtocol
{
	private var mContext:		KEContext
	private var mViewState:		KCSingleViewState
	private var mReturnValue:	CNNativeValue

	public init(context ctxt: KEContext, viewState vstate: KCSingleViewState) {
		mContext	= ctxt
		mViewState	= vstate
		mReturnValue	= .nullValue
	}

	public var isForeground: JSValue {
		get {
			return JSValue(bool: mViewState.isForeground, in: mContext)
		}
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

