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
	private var mSourceURL:		URL?
	private var mProcessManager:	CNProcessManager?
	private var mEnvironment:	CNEnvironment

	public override init(parentViewController parent: KCMultiViewController){
		guard let vm = JSVirtualMachine() else {
			fatalError("Failed to allocate VM")
		}
		mContext	= KEContext(virtualMachine: vm)
		mSourceURL	= nil
		mProcessManager	= nil
		mEnvironment	= CNEnvironment()
		super.init(parentViewController: parent)
	}

	@objc required dynamic public init?(coder: NSCoder) {
		guard let vm = JSVirtualMachine() else {
			fatalError("Failed to allocate VM")
		}
		mContext	= KEContext(virtualMachine: vm)
		mSourceURL	= nil
		mProcessManager	= nil
		mEnvironment	= CNEnvironment()
		super.init(coder: coder)
	}

	public var context: KEContext { get { return mContext }}

	public func setup(sourceURL surl: URL, processManager pmgr: CNProcessManager) {
		mSourceURL	= surl
		mProcessManager	= pmgr
	}

	open override func loadViewContext(rootView root: KCRootView) -> KCSize {
		guard let srcurl = mSourceURL else {
			CNLog(logLevel: .error, message: "No source URL")
			return root.frame.size
		}

		guard let script = srcurl.loadContents() else {
			NSLog("Failed to load script from \(srcurl.absoluteString)")
			return root.frame.size
		}

		guard let procmgr = mProcessManager else {
			NSLog("No process manager")
			return root.frame.size
		}

		let resource = KEResource(baseURL: srcurl)
		let terminfo = CNTerminalInfo(width: 80, height: 25)
		let console  = CNFileConsole()
		let config   = KEConfig(applicationType: .window, doStrict: true, logLevel: .defaultLevel)

		/* Compile library */
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
		switch ambparser.parse(source: script as String) {
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
		let ambcompiler = KMComponentCompiler()
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
		guard let parent = self.parentController as? KMMultiComponentViewController else {
			console.error(string: "Error: No parent view controller ")
			return root.frame.size
		}
		let alibcompiler = KMLibraryCompiler()
		guard alibcompiler.compile(context: mContext, multiComponentViewController: parent, resource: resource, processManager: procmgr, console: console, environment: mEnvironment, config: config) else {
			console.error(string: "Error: Failed to compile")
			return root.frame.size
		}

		/* Link components */
		let linker = KMComponentLinker(parentViewController: self)
		linker.visit(component: topcomp)

		/* Setup root view*/
		if let view = topcomp as? KCView {
			root.setup(childView: view)
		} else {
			console.error(string: "Component is NOT view")
		}
		return root.fittingSize
	}
}
