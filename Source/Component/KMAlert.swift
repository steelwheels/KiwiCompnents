/**
 * @file	KMAlert.swift
 * @brief	Define KMAlert class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiControls
import Foundation
import KiwiControls
import KiwiEngine
import CoconutData
import JavaScriptCore

public class KMAlert
{
	private var mContext:		KEContext
	private var mViewController:	KCViewController

	public init(context ctxt: KEContext, viewController viewcont: KCViewController) {
		mContext	= ctxt
		mViewController = viewcont
	}

	public func execute(messageValue msgval: JSValue) -> JSValue {
		var result: Bool = false
		let message: String
		if let str = msgval.toString() {
			message = str
		} else {
			message = "undefined"
		}
		if Thread.isMainThread {
			result = self.show(message: message)
		} else {
			let semaphore = DispatchSemaphore(value: 0)
			CNExecuteInMainThread(doSync: false, execute: {
				() -> Void in
				result = self.show(message: message)
				semaphore.signal()
			})
			semaphore.wait()
		}
		return JSValue(bool: result, in: mContext)
	}

	private func show(message msg: String) -> Bool {
		let err = NSError.informationNotice(message: msg)
		let result: Bool
		switch KCAlert.runModal(error: err, in: mViewController) {
		case .OK:	result = true
		case .Cancel:	result = false
		@unknown default:
			CNLog(logLevel: .error, message: "Unknown runModal result")
			result = false
		}
		return result
	}
}

