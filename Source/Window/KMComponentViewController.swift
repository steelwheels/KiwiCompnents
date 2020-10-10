/**
 * @file	KMPlaneViewController.swift
 * @brief	Define KMPlaneViewController class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiControls
import Amber
import KiwiEngine
import KiwiLibrary
import CoconutData
import JavaScriptCore
import Foundation
#if os(OSX)
import AppKit
#else
import UIKit
#endif

open class KMComponentViewController: KCPlaneViewController
{
	private var mContext:		KEContext? = nil
	private var mProcessManager:	CNProcessManager = CNProcessManager()

	public var scriptURL:		URL?	// URL of AmberScript

	open override func loadViewContext(rootView root: KCRootView) -> KCSize {
		let script: String
		if let scrurl = scriptURL {
			if let scr = scrurl.loadContents() {
				script = scr as String
			} else {
				NSLog("Failed to load URL: \(scrurl.path)")
				return root.frame.size
			}
		} else {
			NSLog("No script URL")
			return root.frame.size
		}

		guard let vm = JSVirtualMachine() else {
			NSLog("Failed to allocate VM")
			return root.frame.size
		}

		/* Setup context */
		let ctxt = KEContext(virtualMachine: vm)
		mContext = ctxt

		let terminfo = CNTerminalInfo(width: 80, height: 25)
		let env	     = CNEnvironment()
		let console  = CNFileConsole()
		let config   = KEConfig(applicationType: .window, doStrict: true, logLevel: .defaultLevel)

		let libcompiler = KLCompiler()
		guard libcompiler.compileBase(context: ctxt, terminalInfo: terminfo, environment: env, console: console, config: config) else {
			console.error(string: "Failed to compile base")
			return root.frame.size
		}
		guard libcompiler.compileLibrary(context: ctxt, sourceFile: .none, processManager: mProcessManager, environment: env, console: console, config: config) else {
			console.error(string: "Failed to compile library")
			return root.frame.size
		}

		/* Compile the Amber script */
		let ambparser = AMBParser()
		let frame: AMBFrame
		switch ambparser.parse(source: script) {
		case .ok(let frm):
			frame = frm
		case .error(let err):
			console.error(string: "Error: \(err.toString())")
			return root.frame.size
		@unknown default:
			console.error(string: "Error: Unknown switch condition (1)")
			return root.frame.size
		}
		
		let ambcompiler = KMCompiler()
		let topcomp: AMBComponent
		switch ambcompiler.compile(frame: frame, context: ctxt) {
		case .ok(let comp):
			topcomp = comp
		case .error(let err):
			console.error(string: "Error: \(err.toString())")
			return root.frame.size
		@unknown default:
			console.error(string: "Error: Unknown switch condition (2)")
			return root.frame.size
		}

		/* Setup root view*/
		if let view = topcomp as? KCView {
			root.setup(childView: view)
		} else {
			console.error(string: "Component is NOT view")
		}

		let fitsize = root.fittingSize
		NSLog("root size = \(fitsize.description)")
		return fitsize
	}
}
