/**
 * @file	KMCompiler.swift
 * @brief	Define KMCompiler protocol
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiShell
import KiwiLibrary
import KiwiEngine
import KiwiControls
import CoconutData
import JavaScriptCore
import Foundation

public class KMComponentCompiler: KLExternalCompiler
{
	private var mViewController:	KCViewController

	public init(viewController viewcont: KCViewController) {
		mViewController = viewcont
	}

	public func compileExternalModule(context ctxt: KEContext, config conf: KEConfig) -> Bool {
		let result: Bool
		switch conf.applicationType {
		case .window:
			result = compileForWindow(context: ctxt)
		case .terminal:
			result = true
		}
		return result
	}

	private func compileForWindow(context ctxt: KEContext) -> Bool {
		/* alert */
		let alertFunc: @convention(block) (_ value: JSValue) -> JSValue = {
			(_ value: JSValue) -> JSValue in
			let alert = KMAlert(viewController: self.mViewController)
			return alert.execute(messageValue: value, context: ctxt)
		}
		ctxt.set(name: "alert", function: alertFunc)
		return true
	}

}
