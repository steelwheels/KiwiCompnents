/**
 * @file	KMVisitor.swift
 * @brief	Define KMVisitor class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import CoconutData

open class KMVisitor
{
	public func visit(component comp: AMBComponent) {
		if let txt = comp as? KMTextField {
			visit(textField: txt)
		} else if let button = comp as? KMButton {
			visit(button: button)
		} else if let image = comp as? KMImage {
			visit(image: image)
		} else if let stack = comp as? KMStackView {
			visit(stackView: stack)
		} else if let term = comp as? KMTerminalView {
			visit(terminalView: term)
		} else {
			CNLog(logLevel: .error, message: "Unknown component")
		}
	}

	open func visit(button view: KMButton){ }
	open func visit(image view: KMImage){ }
	open func visit(stackView view: KMStackView){ }
	open func visit(terminalView view: KMTerminalView){ }
	open func visit(textField field: KMTextField){ }
}
