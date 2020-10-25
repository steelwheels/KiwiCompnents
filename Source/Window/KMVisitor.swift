/**
 * @file	KMVisitor.swift
 * @brief	Define KMVisitor class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber

open class KMVisitor
{
	public func visit(component comp: AMBComponent) {
		if let button = comp as? KMButton {
			visit(button: button)
		} else if let stack = comp as? KMStackView {
			visit(stackView: stack)
		} else if let term = comp as? KMTerminalView {
			visit(terminalView: term)
		} else {
			NSLog("Unknown component")
		}
	}

	open func visit(button view: KMButton){ }
	open func visit(stackView view: KMStackView){ }
	open func visit(terminalView view: KMTerminalView){ }
}
