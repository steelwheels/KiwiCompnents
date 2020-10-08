/**
 * @file	KMCompiler.swift
 * @brief	Define KMCompiler class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import KiwiEngine

public class KMCompiler: AMBCompiler
{
	open override func addAllocators() {
		super.addAllocators()

		let manager = AMBComponentManager.shared
		manager.addAllocator(className: "Button", allocatorFunc: {
			(_ robj: AMBReactObject, _ ctxt: KEContext) -> AllocationResult in
			let newcomp = KMButton()
			if let err = newcomp.setup(reactObject: robj, context: ctxt) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "VBox", allocatorFunc: {
			(_ robj: AMBReactObject, _ ctxt: KEContext) -> AllocationResult in
			let newcomp  = KMStackView()
			newcomp.axis = .vertical
			if let err = newcomp.setup(reactObject: robj, context: ctxt) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
	}
}

