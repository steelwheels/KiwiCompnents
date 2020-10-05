/**
 * @file	KMCompiler.swift
 * @brief	Define KMCompiler protocol
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiControls
import KiwiLibrary
import KiwiEngine
import CoconutData
import JavaScriptCore

public class KMComponentCompiler: KLExternalCompiler
{
	private var mViewController:	KCViewController

	public init(viewController vcont: KCViewController) {
		mViewController = vcont
	}

	public func compileExternalModule(context ctxt: KEContext, config conf: KEConfig) -> Bool {
		return compileBuildinObjects(context: ctxt)
	}

	private func compileBuildinObjects(context ctxt: KEContext) -> Bool {
		/* ObservedValueTable */
		CNLog(logLevel: .detail, message: "Define ObservedValueTable function")
		let observedValueTableAllocator: @convention(block) () -> JSValue = {
			() -> JSValue in
			let table = KMObservedValueTable(context: ctxt)
			return JSValue(object: table, in: ctxt)
		}
		ctxt.set(name: "ObservedValueTable", function: observedValueTableAllocator)

		return true
	}
}
