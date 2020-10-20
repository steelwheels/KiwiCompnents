/**
 * @file	KMCompiler.swift
 * @brief	Define KMCompiler class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import KiwiEngine
import CoconutData

public class KMCompiler: AMBCompiler
{
	open override func addAllocators() {
		super.addAllocators()

		let manager = AMBComponentManager.shared
		manager.addAllocator(className: "Button", allocatorFunc: {
			(_ robj: AMBReactObject, _ ctxt: KEContext, _ pmgr: CNProcessManager, _ env: CNEnvironment) -> AllocationResult in
			let newcomp = KMButton()
			if let err = newcomp.setup(reactObject: robj, context: ctxt, processManager: pmgr, environment: env) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "VBox", allocatorFunc: {
			(_ robj: AMBReactObject, _ ctxt: KEContext, _ pmgr: CNProcessManager, _ env: CNEnvironment) -> AllocationResult in
			let newcomp  = KMStackView()
			newcomp.axis = .vertical
			if let err = newcomp.setup(reactObject: robj, context: ctxt, processManager: pmgr, environment: env) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "Terminal", allocatorFunc: {
			(_ robj: AMBReactObject, _ ctxt: KEContext, _ pmgr: CNProcessManager, _ env: CNEnvironment) -> AllocationResult in
			let newcomp  = KMTerminalView()
			if let err = newcomp.setup(reactObject: robj, context: ctxt, processManager: pmgr, environment: env) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "Shell", allocatorFunc: {
			(_ robj: AMBReactObject, _ ctxt: KEContext, _ pmgr: CNProcessManager, _ env: CNEnvironment) -> AllocationResult in
			let newcomp = KMShell()
			if let err = newcomp.setup(reactObject: robj, context: ctxt, processManager: pmgr, environment: env) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
	}

	public func compileLibrary(context ctxt: KEContext, parentViewController parent: KMMultiComponentViewController) -> NSError? {
		let segue = KMSegue(parentViewController: parent, context: ctxt)
		ctxt.set(name: "segue", object: segue)
		return nil
	}
}

