//
//  ViewController.swift
//  UnitTest
//
//  Created by Tomoo Hamada on 2020/09/24.
//

import Amber
import KiwiComponents
import KiwiControls
import KiwiEngine
import KiwiLibrary
import CoconutData
import Cocoa
import JavaScriptCore

class ViewController: KMMultiComponentViewController
{
	public static let TerminalViewControllerName	= "term"

	private var mIs1stAppear: Bool	= false

	open override func viewDidLoad() {
		super.viewDidLoad()

		/* Print detail logs */
		let _ = KCLogManager.shared
		CNPreference.shared.systemPreference.logLevel = .warning // .detail

		/* Add subview */
		if let scrurl = CNFilePath.URLForResourceFile(fileName: "sample-1", fileExtension: "amb") {
			if let script = scrurl.loadContents() as String? {
				super.pushViewController(script: script)
			} else {
				NSLog("Failed to load sample-1.amb")
			}
		}
	}
}

