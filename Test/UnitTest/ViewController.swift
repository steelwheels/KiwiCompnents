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
	open override func loadResource() -> KEResource {
		if let path = Bundle.main.path(forResource: "sample", ofType: "jspkg") {
			let resource = KEResource.init(baseURL: URL(fileURLWithPath: path))
			let loader   = KEManifestLoader()
			if let err = loader.load(into: resource) {
				NSLog("Failed to load contents of sample.jspkg: \(err.toString())")
			}

			NSLog("resource:")
			let txt = resource.toText().toStrings(terminal: "")
			NSLog(txt.joined(separator: "\n"))
			return resource
		} else {
			NSLog("Failed to load sample.jspkg")
			return super.loadResource()
		}
	}

	open override func viewDidAppear() {
		super.viewDidAppear()

		/* Update log level */
		let _ = KCLogManager.shared
		let syspref = CNPreference.shared.systemPreference
		syspref.logLevel = .detail

		/* add sub view */
		if let res = self.resource {
			let _ = super.pushViewController(source: .mainView(res))
		} else {
			NSLog("Failed to get resource")
		}
	}
}

