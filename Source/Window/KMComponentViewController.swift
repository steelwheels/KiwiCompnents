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

public enum KMSource {
	case	mainView(KEResource)			// The resource contains the main view
	case	subView(KEResource, String)		// The resource contains the sub view, the sub view name
}

open class KMComponentViewController: KCSingleViewController
{
	private var mContext:		KEContext
	private var mSource:		KMSource?
	private var mViewState:		KMViewState?
	private var mProcessManager:	CNProcessManager?
	private var mResource:		KEResource?
	private var mEnvironment:	CNEnvironment
	private var mDidAlreadyLinked:	Bool

	public override init(parentViewController parent: KCMultiViewController){
		guard let vm = JSVirtualMachine() else {
			fatalError("Failed to allocate VM")
		}
		mContext		= KEContext(virtualMachine: vm)
		mSource			= nil
		mViewState		= nil
		mProcessManager		= nil
		mResource		= nil
		mEnvironment		= CNEnvironment()
		mDidAlreadyLinked	= false
		super.init(parentViewController: parent)
	}

	@objc required dynamic public init?(coder: NSCoder) {
		guard let vm = JSVirtualMachine() else {
			fatalError("Failed to allocate VM")
		}
		mContext		= KEContext(virtualMachine: vm)
		mSource			= nil
		mViewState		= nil
		mProcessManager		= nil
		mResource		= nil
		mEnvironment		= CNEnvironment()
		mDidAlreadyLinked	= false
		super.init(coder: coder)
	}

	public var context: KEContext { get { return mContext }}

	public var state: KMViewState {
		get {
			if let state = mViewState {
				return state
			} else {
				fatalError("Uninitialized state")
			}
		}
	}

	public func setup(source src: KMSource, processManager pmgr: CNProcessManager) {
		mSource		= src
		mProcessManager	= pmgr
	}

	open override func loadViewContext(rootView root: KCRootView) {
		let console  = super.globalConsole

		guard let src = mSource else {
			console.error(string: "No source file for new view\n")
			return
		}

		guard let procmgr = mProcessManager else {
			console.error(string: "No process manager\n")
			return
		}

		let script:	String
		let resource:	KEResource
		switch src {
		case .mainView(let res):
			if let scr = res.loadView() {
				script		= scr
				resource	= res
			} else {
				console.error(string: "Failed to load main view\n")
				return
			}
		case .subView(let res, let name):
			if let scr = res.loadSubview(identifier: name) {
				script		= scr
				resource	= res
			} else {
				console.error(string: "Failed to load sub view named: \(name)\n")
				return
			}
		}
		mResource = resource

		let terminfo = CNTerminalInfo(width: 80, height: 25)
		let loglevel = CNPreference.shared.systemPreference.logLevel
		let config   = KEConfig(applicationType: .window, doStrict: true, logLevel: loglevel)

		if loglevel.isIncluded(in: .detail) {
			let txt = resource.toText()
			console.print(string: "Resource for amber view\n")
			console.print(string: txt.toStrings(terminal: "").joined(separator: "\n"))
		}

		/* Allocate the view state */
		let viewstate = KMViewState(context: context, viewState: self.viewState)
		mViewState = viewstate

		/* Compile library */
		let libcompiler = KLCompiler()
		guard libcompiler.compileBase(context: mContext, terminalInfo: terminfo, environment: mEnvironment, console: console, config: config) else {
			console.error(string: "Failed to compile base\n")
			return
		}
		guard libcompiler.compileLibrary(context: mContext, resource: resource, processManager: procmgr, environment: mEnvironment, console: console, config: config) else {
			console.error(string: "Failed to compile library\n")
			return
		}

		/* Compile the Amber script */
		let ambparser = AMBParser()
		let frame: AMBFrame
		switch ambparser.parse(source: script as String) {
		case .ok(let frm):
			frame = frm
			/* dump the frame */
			if loglevel.isIncluded(in: .detail) {
				let dumper = AMBFrameDumper()
				let txt    = dumper.dumpToText(frame: frm)
				CNLog(logLevel: .detail, text: txt)
			}
		case .error(let err):
			console.error(string: "Error: \(err.toString())\n")
			return
		@unknown default:
			console.error(string: "Error: Unknown switch condition (1)\n")
			return
		}

		/* Allocate the component */
		let ambcompiler = KMComponentCompiler()
		let topcomp: AMBComponent
		switch ambcompiler.compile(frame: frame, context: context, processManager: procmgr, resource: resource, environment: mEnvironment, config: config, console: console) {
		case .ok(let comp):
			topcomp = comp
			/* dump the component */
			if loglevel.isIncluded(in: .detail) {
				let dumper = AMBComponentDumper()
				let txt    = dumper.dumpToText(component: comp)
				CNLog(logLevel: .detail, text: txt)
			}
		case .error(let err):
			console.error(string: "Error: \(err.toString())\n")
			return
		@unknown default:
			console.error(string: "Error: Unknown switch condition (2)\n")
			return
		}

		/* Compile library for component*/
		let alibcompiler = KMLibraryCompiler()
		guard alibcompiler.compile(context: mContext, viewController: self, resource: resource, processManager: procmgr, console: console, environment: mEnvironment, config: config) else {
			console.error(string: "Error: Failed to compile\n")
			return
		}

		/* Setup root view*/
		if let view = topcomp as? KCView {
			root.setup(childView: view)
		} else {
			console.error(string: "Component is NOT view\n")
		}
	}

	#if os(OSX)
	open override func viewDidAppear() {
		super.viewDidAppear()
		doViewDidAppear()
	}
	#else
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		doViewDidAppear()
	}
	#endif

	private func doViewDidAppear() {
		/* Link components */
		if !mDidAlreadyLinked {
			if let res = mResource, let root = self.rootView {
				let linker = KMComponentLinker(viewController: self, resource: res)
				for subview in root.subviews {
					if let subcomp = subview as? AMBComponent {
						linker.visit(component: subcomp)
					}
				}
				/* Replace global console */
				if let console = linker.result {
					super.globalConsole = console
				}
			}
			mDidAlreadyLinked = true
		}
		/* dump for debug */
		if CNPreference.shared.systemPreference.logLevel.isIncluded(in: .detail) {
			if let root = self.rootView {
				let dumper = KCViewDumper()
				dumper.dump(view: root)
			} else {
				CNLog(logLevel: .error, message: "No root view")
			}
		}
	}
}
