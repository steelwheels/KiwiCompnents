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

class ViewController: KMComponentViewController
{
	open override func loadViewContext(rootView root: KCRootView) -> KCSize {
		/* Print detail logs */
		let _ = KCLogManager.shared
		CNPreference.shared.systemPreference.logLevel = .detail

		if let scrurl = CNFilePath.URLForResourceFile(fileName: "sample-1", fileExtension: "amb") {
			self.scriptURL = scrurl
		} else {
			NSLog("Failed to allocate URL")
		}
		return super.loadViewContext(rootView: root)
	}
}

