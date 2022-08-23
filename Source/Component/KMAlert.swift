/**
 * @file	KMAlert.swift
 * @brief	Define KMAlert class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import KiwiControls
import Amber
import KiwiEngine
import KiwiLibrary
import CoconutData
import JavaScriptCore
import Foundation

public class KMAlert
{
	public static func execute(type typval: JSValue, message msg: JSValue, callback cbfunc: JSValue, viewController vcont: KMComponentViewController, context ctxt: KEContext) -> Void {
		CNExecuteInMainThread(doSync: false, execute: {
			if let atype = valueToType(value: typval),  let msgstr = msg.toString() {
				KCAlert.alert(type: atype, messgage: msgstr, in: vcont, callback: {
					(_ retval: Int) -> Void in
					if let retobj = JSValue(int32: Int32(retval), in: ctxt) {
						cbfunc.call(withArguments: [retobj])
					} else {
						CNLog(logLevel: .error, message: "Failed to allocate return value", atFunction: #function, inFile: #file)
						cbfunc.call(withArguments: [])
					}
				})
			} else {
				if let retobj = JSValue(int32: -1, in: ctxt) {
					cbfunc.call(withArguments: [retobj])
				} else {
					cbfunc.call(withArguments: [])
				}
			}
		})
	}

	private static func valueToType(value val: JSValue) -> CNAlertType? {
		if let num = val.toNumber() {
			if let atype = CNAlertType(rawValue: num.intValue) {
				return atype
			}
		}
		return nil
	}
}

