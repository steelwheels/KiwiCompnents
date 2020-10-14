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
		CNPreference.shared.systemPreference.logLevel = .warning // .detail

		if let scrurl = CNFilePath.URLForResourceFile(fileName: "sample-1", fileExtension: "amb") {
			let pmgr = CNProcessManager()
			let env  = CNEnvironment()

			let DO_USE_SCRIPT = false
			if DO_USE_SCRIPT {
				if let srcurl = CNFilePath.URLForResourceFile(fileName: "sample-2", fileExtension: "js") {
					let srcfile = srcurl.absoluteString
					env.setString(name: KMShell.SourceFileVariableName, value: srcfile)
					NSLog("Source file: \(srcfile)")
				}
			}

			setup(scriptURL: scrurl, processManager: pmgr, environment: env)
		} else {
			NSLog("Failed to allocate URL")
		}
		return super.loadViewContext(rootView: root)
	}
}

