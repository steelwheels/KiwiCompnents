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
	private var mViewController:	KCViewController

	public init(viewController viewcont: KCViewController) {
		mViewController = viewcont
	}

	public func execute(messageValue msgval: JSValue, context ctxt: KEContext) -> JSValue {
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
		return JSValue(bool: result, in: ctxt)
	}

	private func show(message msg: String) -> Bool {
		let err = NSError.informationNotice(message: msg)
		let result: Bool
		switch KCAlert.runModal(error: err, in: mViewController) {
		case .Abort:	result = true
		case .Continue:	result = false
		case .Stop:	result = true
		}
		return result
	}
}

