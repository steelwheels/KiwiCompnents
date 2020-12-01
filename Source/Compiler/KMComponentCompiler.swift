/**
 * @file	KMComponentCompiler.swift
 * @brief	Define KMComponentCompiler class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import KiwiEngine
import KiwiLibrary
import JavaScriptCore
import CoconutData

public class KMComponentCompiler: AMBFrameCompiler
{
	open override func addAllocators() {
		super.addAllocators()

		let manager = AMBComponentManager.shared
		manager.addAllocator(className: "Button", allocatorFunc: {
			(_ robj: AMBReactObject) -> AllocationResult in
			let newcomp = KMButton()
			if let err = newcomp.setup(reactObject: robj) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "VBox", allocatorFunc: {
			(_ robj: AMBReactObject) -> AllocationResult in
			let newcomp  = KMStackView()
			newcomp.axis = .vertical
			if let err = newcomp.setup(reactObject: robj) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "Terminal", allocatorFunc: {
			(_ robj: AMBReactObject) -> AllocationResult in
			let newcomp  = KMTerminalView()
			if let err = newcomp.setup(reactObject: robj) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "Shell", allocatorFunc: {
			(_ robj: AMBReactObject) -> AllocationResult in
			let newcomp = KMShell()
			if let err = newcomp.setup(reactObject: robj) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "Label", allocatorFunc: {
			(_ robj: AMBReactObject) -> AllocationResult in
			let newcomp = KMTextField()
			if let err = newcomp.setup(reactObject: robj) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
	}


}


