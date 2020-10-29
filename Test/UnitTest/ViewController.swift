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

	private var mContext: KEContext? = nil

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


	open override func viewDidLoad() {
		super.viewDidLoad()

		/* Print detail logs */
		let _ = KCLogManager.shared
		CNPreference.shared.systemPreference.logLevel = .warning // .detail

		/* get context */
		let ctxt: KEContext
		if let c = mContext {
			ctxt = c
		} else {
			let vm      = JSVirtualMachine()
			let newctxt = KEContext(virtualMachine: vm!)
			mContext    = newctxt
			ctxt	    = newctxt
		}

		/* Add subview */
		if let res = super.resource {
			if let url = res.URLOfView(identifier: "sample_view") {
				super.pushViewController(sourceURL: url, context: ctxt)
			}
		}

/*
		if let scrurl = CNFilePath.URLForResourceFile(fileName: "sample-1", fileExtension: "amb") {
			if let script = scrurl.loadContents() as String? {
				super.pushViewController(script: script)
			} else {
				NSLog("Failed to load sample-1.amb")
			}
		}*/
	}
}

