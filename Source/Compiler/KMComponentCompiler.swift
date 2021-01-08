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
			(_ robj: AMBReactObject, _ cons: CNConsole) -> AllocationResult in
			let newcomp = KMButton()
			if let err = newcomp.setup(reactObject: robj, console: cons) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "CheckBox", allocatorFunc: {
			(_ robj: AMBReactObject, _ cons: CNConsole) -> AllocationResult in
			let newcomp = KMCheckBox()
			if let err = newcomp.setup(reactObject: robj, console: cons) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "HBox", allocatorFunc: {
			(_ robj: AMBReactObject, _ cons: CNConsole) -> AllocationResult in
			let newcomp  = KMStackView()
			newcomp.axis = .horizontal
			if let err = newcomp.setup(reactObject: robj, console: cons) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "Image", allocatorFunc: {
			(_ robj: AMBReactObject, _ cons: CNConsole) -> AllocationResult in
			let newcomp = KMImage()
			if let err = newcomp.setup(reactObject: robj, console: cons) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "Label", allocatorFunc: {
			(_ robj: AMBReactObject, _ cons: CNConsole) -> AllocationResult in
			let newcomp = KMTextEdit()
			newcomp.mode = .label
			if let err = newcomp.setup(reactObject: robj, console: cons) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "Shell", allocatorFunc: {
			(_ robj: AMBReactObject, _ cons: CNConsole) -> AllocationResult in
			let newcomp = KMShell()
			if let err = newcomp.setup(reactObject: robj, console: cons) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "Terminal", allocatorFunc: {
			(_ robj: AMBReactObject, _ cons: CNConsole) -> AllocationResult in
			let newcomp  = KMTerminalView()
			if let err = newcomp.setup(reactObject: robj, console: cons) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "TextField", allocatorFunc: {
			(_ robj: AMBReactObject, _ cons: CNConsole) -> AllocationResult in
			let newcomp = KMTextEdit()
			newcomp.mode = .view(40)
			if let err = newcomp.setup(reactObject: robj, console: cons) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
		manager.addAllocator(className: "VBox", allocatorFunc: {
			(_ robj: AMBReactObject, _ cons: CNConsole) -> AllocationResult in
			let newcomp  = KMStackView()
			newcomp.axis = .vertical
			if let err = newcomp.setup(reactObject: robj, console: cons) {
				return .error(err)
			} else {
				return .ok(newcomp)
			}
		})
	}
}


