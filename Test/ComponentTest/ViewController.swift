//
//  ViewController.swift
//  ComponentTest
//
//  Created by Tomoo Hamada on 2020/06/13.
//  Copyright © 2020 Steel Wheels Project. All rights reserved.
//

import KiwiControls
import KiwiComponents
import CoconutData
import Cocoa

class ViewController: KCPlaneViewController
{
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	open override func loadViewContext(rootView root: KCRootView) -> KCSize {
		let button = KCButton()
		button.title		= "Select by menu"
		button.isEnabled	= true
		button.buttonPressedCallback = {
			() -> Void in self.openPopupMenu()
		}
		root.setup(childView: button)
		return button.fittingSize
	}

	open override func viewDidAppear() {
		NSLog("viewDidAppear")
		super.viewDidAppear()
	}

	private func openPopupMenu() {
		let lab0 = menuItem(menuId: 0, menuLabel: "label0")
		let lab1 = menuItem(menuId: 1, menuLabel: "label1")
		let labs = CNNativeValue.arrayValue([lab0, lab1])

		let dict: Dictionary<String, CNNativeValue> = [
			"class":    .stringValue(KMClass.contextualMenu.rawValue),
			"contents": labs
		]
		let obj = CNNativeValue.dictionaryValue(dict)

		let input  = KMConnection()
		let output = KMConnection()
		let popup  = KMPopupMenu()

		let err = popup.connect(script: obj, input: input, output: output)
		switch err {
		case .noError:
			NSLog("connect: done")
		default:
			NSLog("connect: [Error] \(err.description)")
		}

		if let root = super.rootView {
			let menuid = popup.show(at: NSEvent.mouseLocation, in: root)
			if let mid = menuid {
				NSLog("Show ... Select \(mid)")
			} else {
				NSLog("Show ... Not selected")
			}
		}
	}

	private func menuItem(menuId mid: Int, menuLabel mlabel: String) -> CNNativeValue {
		let dict : Dictionary<String, CNNativeValue> = [
			"id":    CNNativeValue.numberValue(NSNumber(value: mid)),
			"label": CNNativeValue.stringValue(mlabel)
		]
		return .dictionaryValue(dict)
	}
}

