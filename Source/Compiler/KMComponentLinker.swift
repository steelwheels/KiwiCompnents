/**
 * @file	KMComponentLinker.swift
 * @brief	Define KMComponentLinker class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import KiwiEngine
import KiwiControls
import CoconutData
import JavaScriptCore
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

	public override func visit(bitmap view: KMBitmap){
		/* Do nothing */
	}

	public override func visit(button view: KMButton){
		/* Do nothing */
	}

	public override func visit(cardView view: KMCardView){
		let subviews = view.arrangedSubviews()
		for subview in subviews {
			if let subcomp = subview as? AMBComponent {
				self.visit(component: subcomp)
			}
		}
	}

	public override func visit(checkBox view: KMCheckBox){
		/* Do nothing */
	}

	public override func visit(radioButtons view: KMRadioButtons){
		/* Do nothing */
	}

	public override func visit(contactDatabase db: KMContactDatabase){
		/* Do nothing */
	}

	public override func visit(graphics2D view: KMGraphics2D){
		/* Do nothing */
	}

	public override func visit(drawingView view: KMDrawingView) {
		/* Do nothing */
	}

	public override func visit(icon view: KMIcon){
		/* Do nothing */
	}

	public override func visit(image view: KMImage){
		/* Do nothing */
	}

	public override func visit(popupMenu view: KMPopupMenu){
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

	public override func visit(stepper view: KMStepper){
		/* Do nothing */
	}

	public override func visit(labeledStackView view: KMLabeledStackView) {
		let subviews = view.contentsView.arrangedSubviews()
		for subview in subviews {
			if let subcomp = subview as? AMBComponent {
				self.visit(component: subcomp)
			}
		}
	}

	public override func visit(tableView view: KMTableView) {
		/* Do nothing */
	}

	public override func visit(collectionView view: KMCollectionView) {
		/* Do nothing */
	}

	public override func visit(terminalView view: KMTerminalView){
		view.startShell(viewController: mParentController, resource: mResource)
		if mFileConsole == nil {
			mFileConsole = CNFileConsole(input: view.inputFile, output: view.outputFile, error: view.errorFile)
		}
	}

	public override func visit(storage strg: KMStorage) {
		/* Do nothing */
	}
}
