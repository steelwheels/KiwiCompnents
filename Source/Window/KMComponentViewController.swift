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
	private var mContext:		KEContext
	private var mScriptURL:		URL?
	private var mProcessManager:	CNProcessManager?
	private var mEnvironment:	CNEnvironment?

	public override init(){
		guard let vm = JSVirtualMachine() else {
			fatalError("Failed to allocate VM")
		}
		mContext	= KEContext(virtualMachine: vm)
		mScriptURL	= nil
		mProcessManager	= nil
		mEnvironment	= nil
		super.init()
	}

	@objc required dynamic public init?(coder: NSCoder) {
		guard let vm = JSVirtualMachine() else {
			fatalError("Failed to allocate VM")
		}
		mContext	= KEContext(virtualMachine: vm)
		mScriptURL	= nil
		mProcessManager	= nil
		mEnvironment	= nil
		super.init(coder: coder)
	}

	public func setup(scriptURL scrurl: URL, processManager pmgr: CNProcessManager, environment env: CNEnvironment) {
		mScriptURL	= scrurl
		mProcessManager	= pmgr
		mEnvironment	= env
	}

	open override func loadViewContext(rootView root: KCRootView) -> KCSize {
		let script: String
		if let scrurl = mScriptURL {
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

		guard let procmgr = mProcessManager else {
			NSLog("No process manager")
			return root.frame.size
		}

		guard let env = mEnvironment else {
			NSLog("No environment")
			return root.frame.size
		}

		let terminfo = CNTerminalInfo(width: 80, height: 25)
		let console  = CNFileConsole()
		let config   = KEConfig(applicationType: .window, doStrict: true, logLevel: .defaultLevel)

		let libcompiler = KLCompiler()
		guard libcompiler.compileBase(context: mContext, terminalInfo: terminfo, environment: env, console: console, config: config) else {
			console.error(string: "Failed to compile base")
			return root.frame.size
		}
		guard libcompiler.compileLibrary(context: mContext, sourceFile: .none, processManager: procmgr, environment: env, console: console, config: config) else {
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
		switch ambcompiler.compile(frame: frame, context: mContext, processManager: procmgr, environment: env) {
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
