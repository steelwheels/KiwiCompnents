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
	private var mViewState:		KMViewState
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
		mViewState		= KMViewState()
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
		mViewState		= KMViewState()
		mProcessManager		= nil
		mResource		= nil
		mEnvironment		= CNEnvironment()
		mDidAlreadyLinked	= false
		super.init(coder: coder)
	}

	public var context: KEContext { get { return mContext }}

	public var state: KMViewState {
		get { return mViewState }
	}

	public func setup(source src: KMSource, processManager pmgr: CNProcessManager) {
		mSource		= src
		mProcessManager	= pmgr
	}

	open override func loadContext() -> KCView? {
		let console  = super.globalConsole

		guard let src = mSource else {
			console.error(string: "No source file for new view\n")
			return nil
		}

		guard let procmgr = mProcessManager else {
			console.error(string: "No process manager\n")
			return nil
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
				return nil
			}
		case .subView(let res, let name):
			if let scr = res.loadSubview(identifier: name) {
				script		= scr
				resource	= res
			} else {
				console.error(string: "Failed to load sub view named: \(name)\n")
				return nil
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

		/* Compile library */
		let libcompiler = KLCompiler()
		guard libcompiler.compileBase(context: mContext, terminalInfo: terminfo, environment: mEnvironment, console: console, config: config) else {
			console.error(string: "Failed to compile base\n")
			return nil
		}
		guard libcompiler.compileLibrary(context: mContext, resource: resource, processManager: procmgr, environment: mEnvironment, console: console, config: config) else {
			console.error(string: "Failed to compile library\n")
			return nil
		}

		/* Compile the Amber script */
		let ambparser = AMBParser()
		let frame: AMBFrame
		switch ambparser.parse(source: script as String) {
		case .ok(let frm):
			frame = frm
			/* dump the frame */
			if loglevel.isIncluded(in: .detail) {
				console.print(string: "[Output of Amber Parser]\n")
				let dumper = AMBFrameDumper()
				let txt    = dumper.dumpToText(frame: frm)
				txt.print(console: console, terminal: "")
			}
		case .error(let err):
			console.error(string: "Error: \(err.toString())\n")
			return nil
		@unknown default:
			console.error(string: "Error: Unknown switch condition (1)\n")
			return nil
		}

		/* Allocate the component */
		let ambcompiler = KMComponentCompiler()
		let topcomp: AMBComponent
		switch ambcompiler.compile(frame: frame, context: context, processManager: procmgr, resource: resource, environment: mEnvironment, config: config, console: console) {
		case .ok(let comp):
			topcomp = comp
			/* dump the component */
			if loglevel.isIncluded(in: .detail) {
				console.print(string: "[Output of Amber Compiler]\n")
				let dumper = AMBComponentDumper()
				let txt    = dumper.dumpToText(component: comp)
				txt.print(console: console, terminal: "")
			}
		case .error(let err):
			console.error(string: "Error: \(err.toString())\n")
			return nil
		@unknown default:
			console.error(string: "Error: Unknown switch condition (2)\n")
			return nil
		}

		/* Compile library for component*/
		let alibcompiler = KMLibraryCompiler()
		guard alibcompiler.compile(context: mContext, viewController: self, resource: resource, processManager: procmgr, console: console, environment: mEnvironment, config: config) else {
			console.error(string: "Error: Failed to compile\n")
			return nil
		}

		/* Setup root view*/
		return topcomp as? KCView
	}

	open override func errorContext() -> KCView {
		let box = KCStackView()
		box.axis = .vertical

		let message = KCTextField()
		message.text = "Failed to load context"
		box.addArrangedSubView(subView: message)

		let button = KCButton()
		button.title = "Continue"
		button.buttonPressedCallback = {
			() -> Void in
			let cons  = super.globalConsole
			if let parent = self.parentController as? KMMultiComponentViewController {
				if parent.popViewController(returnValue: .nullValue) {
					cons.error(string: "Force to return previous view\n")
				} else {
					cons.error(string: "Failed to pop view\n")
				}
			} else {
				cons.error(string: "No parent controller\n")
			}
		}
		box.addArrangedSubView(subView: button)

		return box
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
			let cons  = super.globalConsole
			if let root = self.rootView {
				let dumper = KCViewDumper()
				dumper.dump(view: root, console: cons)
			} else {
				cons.error(string: "No root view")
			}
		}
	}
}
