/**
 * @file	KMComponentLinker.swift
 * @brief	Define KMComponentLinker class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import KiwiEngine
import CoconutData
import Foundation

public class KMComponentLinker: KMVisitor
{
	private var mParentController:	KMComponentViewController
	private var mResource:		KEResource
	private var mFileConsole:	CNFileConsole?

	public init(viewController parent: KMComponentViewController, resource res: KEResource){
		mParentController = parent
		mResource	  = res
		mFileConsole	  = nil
	}

	public var result: CNFileConsole? { get { return mFileConsole }}

	public override func visit(textEdit view: KMTextEdit){
		/* Do nothing */
	}

	public override func visit(button view: KMButton){
		/* Do nothing */
	}

	public override func visit(checkBox view: KMCheckBox){
		/* Do nothing */
	}

	public override func visit(image view: KMImage){
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
		view.startShell(viewController: mParentController, resource: mResource)
		if mFileConsole == nil {
			let instrm  = view.inputFileHandle
			let outstrm = view.outputFileHandle
			let errstrm = view.errorFileHandle
			mFileConsole = CNFileConsole(input: instrm, output: outstrm, error: errstrm)
		}
	}
}
