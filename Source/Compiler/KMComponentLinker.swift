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

	public override func visit(checkBox view: KMCheckBox){
		/* Do nothing */
	}

	public override func visit(graphics2D view: KMGraphics2D){
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

	public override func visit(tableView view: KMTableView){
		if let celltable = view.cellTable {
			let colnum = celltable.numberOfColumns()
			for cidx in 0..<colnum {
				if let rownum = celltable.numberOfRows(columnIndex: cidx) {
					for ridx in 0..<rownum {
						if let child = view.view(atColumn: cidx, row: ridx) {
							linkEvents(tableView: view, colunm: cidx, row: ridx, childView: child)
						}
					}
				}
			}
		}
	}

	private func linkEvents(tableView table: KMTableView, colunm cidx: Int, row ridx: Int, childView cview: KCView) {
		let tobj = table.reactObject
		if let button = cview as? KMButton {
			button.buttonPressedCallback = {
				() -> Void in
				CNExecuteInUserThread(level: .event, execute: {
					KMComponentLinker.cellPressed(reactObject: tobj, column: cidx, row: ridx)
				})

			}
		} else if let icon = cview as? KMIcon {
			icon.buttonPressedCallback = {
				() -> Void in
				CNExecuteInUserThread(level: .event, execute: {
					KMComponentLinker.cellPressed(reactObject: tobj, column: cidx, row: ridx)
				})
			}
		}
	}

	static private func cellPressed(reactObject robj: AMBReactObject, column cidx: Int, row ridx: Int) {
		if let pressed = robj.immediateValue(forProperty: KMTableView.PressedItem) {
			if let colval = JSValue(int32: Int32(cidx), in: robj.context),
			   let rowval = JSValue(int32: Int32(ridx), in: robj.context) {
				CNExecuteInUserThread(level: .event, execute: {
					let args   = [robj, colval, rowval]
					pressed.call(withArguments: args)
				})
			}
		}
	}

	public override func visit(labeledStackView view: KMLabeledStackView) {
		let subviews = view.contentsView.arrangedSubviews()
		for subview in subviews {
			if let subcomp = subview as? AMBComponent {
				self.visit(component: subcomp)
			}
		}
	}

	public override func visit(terminalView view: KMTerminalView){
		view.startShell(viewController: mParentController, resource: mResource)
		if mFileConsole == nil {
			mFileConsole = CNFileConsole(input: view.inputFile, output: view.outputFile, error: view.errorFile)
		}
	}
}
