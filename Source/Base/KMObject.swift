/**
 * @file	KMObject.swift
 * @brief	Define KMObject class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import KiwiEngine
import JavaScriptCore

public protocol KMObservedValueTableProtocol
{
	func set(_ key: JSValue, _ value: JSValue)
	func get(_ key: JSValue) -> JSValue
	func setScriptCallback(_ key: JSValue, _ callback: JSValue)
}

@objc public class KMObservedValueTable: NSObject, KMObservedValueTableProtocol
{
	public typealias ComponentCallbackFunc	= (_ value: CNNativeValue) -> Void

	private var mContext:			KEContext
	private var mTable:			CNObservedValueTable
	private var mComponentCallbacks:	Dictionary<String, ComponentCallbackFunc>
	private var mScriptCallbacks:		Dictionary<String, JSValue>

	public init(context ctxt: KEContext) {
		mContext   		= ctxt
		mTable    		= CNObservedValueTable()
		mComponentCallbacks	= [:]
		mScriptCallbacks	= [:]
	}

	public func set(_ key: JSValue, _ value: JSValue) {
		if let keystr = key.toString() {
			let nval = value.toNativeValue()
			mTable.setValue(nval, forKey: keystr)
		} else {
			CNLog(logLevel: .error, message: "\(#function) [Error] The key must be string")
		}
	}

	public func get(_ key: JSValue) -> JSValue {
		if let keystr = key.toString() {
			if let val = mTable.value(forKey: keystr) as? CNNativeValue {
				return val.toJSValue(context: mContext)
			}
		} else {
			CNLog(logLevel: .error, message: "\(#function) [Error] The key must be string")
		}
		return JSValue(nullIn: mContext)
	}

	public func setScriptCallback(_ key: JSValue, _ callback: JSValue) {
		if let keystr = key.toString() {
			mScriptCallbacks[keystr] = callback
			if mTable.countOfObservers(forKey: keystr) == 0 {
				setCallback(key: keystr)
			}
		} else {
			CNLog(logLevel: .error, message: "\(#function) [Error] The key must be string")
		}
	}

	public func setComponentCallback(forKey key: String, callback cbfunc: @escaping ComponentCallbackFunc) {
		mComponentCallbacks[key] = cbfunc
		if mTable.countOfObservers(forKey: key) == 0 {
			setCallback(key: key)
		}
	}

	private func setCallback(key keystr: String) {
		mTable.setObserver(forKey: keystr, listnerFunction: {
			(_ val: Any) -> Void in
			if let val = val as? CNNativeValue {
				/* component callback */
				if let cbfunc = self.mComponentCallbacks[keystr] {
					cbfunc(val)
				}
				/* script callback */
				if let cbvar = self.mScriptCallbacks[keystr] {
					let param = val.toJSValue(context: self.mContext)
					cbvar.call(withArguments: [param])
				}
			} else {
				CNLog(logLevel: .error, message: "\(#function) [Error] Can not happen")
			}
		})
	}
}


