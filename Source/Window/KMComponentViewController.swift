/**
 * @file	KMComponentViewController.swift
 * @brief	Define KMComponentViewController class
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

open class KMComponentViewController: KCSingleViewController
{
	private var mContext:		KEContext
	private var mViewName:		String?
	private var mResource:		KEResource?
	private var mProcessManager:	CNProcessManager?
	private var mEnvironment:	CNEnvironment

	public override init(parentViewController parent: KCMultiViewController){
		guard let vm = JSVirtualMachine() else {
			fatalError("Failed to allocate VM")
		}
		mContext	= KEContext(virtualMachine: vm)
		mViewName	= nil
		mResource	= nil
		mProcessManager	= nil
		mEnvironment	= CNEnvironment()
		super.init(parentViewController: parent)
	}

	@objc required dynamic public init?(coder: NSCoder) {
		guard let vm = JSVirtualMachine() else {
			fatalError("Failed to allocate VM")
		}
		mContext	= KEContext(virtualMachine: vm)
		mViewName	= nil
		mResource	= nil
		mProcessManager	= nil
		mEnvironment	= CNEnvironment()
		super.init(coder: coder)
	}

	public func setup(viewName name: String, resource res: KEResource, processManager pmgr: CNProcessManager) {
		mViewName	= name
		mResource	= res
		mProcessManager	= pmgr
	}

	open override func loadViewContext(rootView root: KCRootView) -> KCSize {
		guard let name = mViewName else {
			NSLog("No script name")
			return root.frame.size
		}

		guard let resource = mResource else {
			NSLog("No resource")
			return root.frame.size
		}

		guard let script = resource.loadView(identifier: name) else {
			NSLog("No script for name: \(name)")
			return root.frame.size
		}

		guard let procmgr = mProcessManager else {
			NSLog("No process manager")
			return root.frame.size
		}

		let terminfo = CNTerminalInfo(width: 80, height: 25)
		let console  = CNFileConsole()
		let config   = KEConfig(applicationType: .window, doStrict: true, logLevel: .defaultLevel)

		let libcompiler = KLCompiler()
		guard libcompiler.compileBase(context: mContext, terminalInfo: terminfo, environment: mEnvironment, console: console, config: config) else {
			console.error(string: "Failed to compile base")
			return root.frame.size
		}
		guard libcompiler.compileLibrary(context: mContext, resource: resource, processManager: procmgr, environment: mEnvironment, console: console, config: config) else {
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

		/* Allocate the component */
		let ambcompiler = KMCompiler()
		let topcomp: AMBComponent
		switch ambcompiler.compile(frame: frame, context: mContext, processManager: procmgr, environment: mEnvironment) {
		case .ok(let comp):
			topcomp = comp
		case .error(let err):
			console.error(string: "Error: \(err.toString())")
			return root.frame.size
		@unknown default:
			console.error(string: "Error: Unknown switch condition (2)")
			return root.frame.size
		}

		/* Compile library for component*/
		guard let parentcctrl = self.parentController as? KMMultiComponentViewController else {
			console.error(string: "No parent view controller")
			return root.frame.size
		}
		if let err = ambcompiler.compileLibrary(context: mContext, parentViewController: parentcctrl) {
			console.error(string: "Error: \(err.toString())")
			return root.frame.size
		}

		/* Setup root view*/
		if let view = topcomp as? KCView {
			root.setup(childView: view)
		} else {
			console.error(string: "Component is NOT view")
		}
		return root.fittingSize
	}

	public override func suspend() {
		NSLog("\(#file) suspend")
		mContext.suspend()
	}

	public override func resume() {
		NSLog("\(#file) resume")
		mContext.resume()
	}
}
