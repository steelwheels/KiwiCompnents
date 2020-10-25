/**
 * @file	KMComponentLinker.swift
 * @brief	Define KMComponentLinker class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import Foundation

public class KMComponentLinker: KMVisitor
{
	private var mParentController: KMComponentViewController

	public init(parentViewController parent: KMComponentViewController){
		mParentController = parent
	}

	public override func visit(button view: KMButton){
		/* Do nothing */
	}

	public override func visit(stackView view: KMStackView){
		let subviews = view.arrangedSubviews()
		for subview in subviews {
			if let subcomp = subview as? AMBComponent {
				self.visit(component: subcomp)
			}
		}
	}

	public override func visit(terminalView view: KMTerminalView){
		view.startShell(parentViewController: mParentController)
	}
}
