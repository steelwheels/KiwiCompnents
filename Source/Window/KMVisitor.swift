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
		if let txt = comp as? KMTextEdit {
			visit(textEdit: txt)
		} else if let bitmap = comp as? KMBitmap {
			visit(bitmap: bitmap)
		} else if let button = comp as? KMButton {
			visit(button: button)
		} else if let card = comp as? KMCardView {
			visit(cardView: card)
		} else if let cbox = comp as? KMCheckBox {
			visit(checkBox: cbox)
		} else if let cbox = comp as? KMRadioButtons {
			visit(radioButtons: cbox)
		} else if let cbox = comp as? KMContactDatabase {
			visit(contactDatabase: cbox)
		} else if let gr2d  = comp as? KMGraphics2D {
			visit(graphics2D: gr2d)
		} else if let drw = comp as? KMDrawingView {
			visit(drawingView: drw)
		} else if let icon  = comp as? KMIcon {
			visit(icon: icon)
		} else if let image = comp as? KMImage {
			visit(image: image)
		} else if let stack = comp as? KMLabeledStackView {
			visit(labeledStackView: stack)
		} else if let pmenu = comp as? KMPopupMenu {
			visit(popupMenu: pmenu)
		} else if let stack = comp as? KMStackView {
			visit(stackView: stack)
		} else if let stepper = comp as? KMStepper {
			visit(stepper: stepper)
		} else if let table = comp as? KMTableData {
			visit(tableData: table)
		} else if let table = comp as? KMTableView {
			visit(tableView: table)
		} else if let col = comp as? KMCollectionView {
			visit(collectionView: col)
		} else if let term = comp as? KMTerminalView {
			visit(terminalView: term)
		} else if let dict = comp as? KMDictionaryData {
			visit(dictionaryData: dict)
		} else {
			CNLog(logLevel: .error, message: "Unknown component")
		}
	}

	open func visit(bitmap view: KMBitmap){ }
	open func visit(button view: KMButton){ }
	open func visit(cardView view: KMCardView){ }
	open func visit(checkBox view: KMCheckBox){ }
	open func visit(radioButtons view: KMRadioButtons){ }
	open func visit(contactDatabase view: KMContactDatabase){ }
	open func visit(dictionaryData dict: KMDictionaryData){ }
	open func visit(drawingView view: KMDrawingView){ }
	open func visit(graphics2D view: KMGraphics2D){ }
	open func visit(image view: KMImage){ }
	open func visit(icon view: KMIcon){ }
	open func visit(labeledStackView view: KMLabeledStackView) { }
	open func visit(popupMenu view: KMPopupMenu){ }
	open func visit(stackView view: KMStackView){ }
	open func visit(stepper view: KMStepper){ }
	open func visit(tableData strg: KMTableData){ }
	open func visit(tableView view: KMTableView){ }
	open func visit(collectionView view: KMCollectionView){ }
	open func visit(terminalView view: KMTerminalView){ }
	open func visit(textEdit view: KMTextEdit){ }
}
