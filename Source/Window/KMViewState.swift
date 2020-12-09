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

public class KMViewState
{
	private var mHasReturnValue:	Bool
	private var mReturnValue:	CNNativeValue

	public var hasReturnValue:	Bool 		{ get { return mHasReturnValue 	}}
	public var returnValue: 	CNNativeValue	{ get { return mReturnValue 	}}

	public init() {
		mHasReturnValue		= false
		mReturnValue		= .nullValue
	}

	public func setReturnValue(value val: CNNativeValue) {
		NSLog("KMViewState.setReturnValue")
		mHasReturnValue = true
		mReturnValue    = val
	}
}

@objc public protocol KMViewStateProtocol: JSExport
{
	var readyToReturn:	JSValue { get }
	var returnValue:  	JSValue { get }
}

@objc public class KMViewStateValue: NSObject, KMViewStateProtocol
{
	private var	mContext:	KEContext
	private var 	mViewState:	KMViewState

	public init(context ctxt: KEContext, viewState vstate: KMViewState) {
		mContext   = ctxt
		mViewState = vstate
	}

	public var readyToReturn: JSValue {
		get {
			NSLog("KMViewStateValue.readyToReturn \(mViewState.hasReturnValue)")
			return JSValue(bool: mViewState.hasReturnValue, in: mContext)
		}
	}

	public var returnValue: JSValue {
		get {
			NSLog("KMViewStateValue.returnValue \(String(describing: mViewState.returnValue.toSize()))")
			return mViewState.returnValue.toJSValue(context: mContext)
		}
	}
}

/*


@objc public class KMViewState: NSObject, KMViewStateProtocol
{
	private var mContext:		KEContext


	public init(context ctxt: KEContext) {
		mContext		= ctxt
		mHasReturnValue		= false
		mReturnValue		= .nullValue
	}

	public var readyToReturn: JSValue {
		get {
			return JSValue(bool: mHasReturnValue, in: mContext)
		}
	}

	public func setReturnValue(value val: CNNativeValue) {
		mHasReturnValue = true
		mReturnValue    = val
	}

	public var returnValue: JSValue {
		get { return mReturnValue.toJSValue(context: mContext) }
	}
}

*/

