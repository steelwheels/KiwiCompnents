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
		if let state = mViewState {
			return state
		} else {
			fatalError("Uninitialized state")
		}
	}

	public func setup(source src: KMSource, processManager pmgr: CNProcessManager) {
		mSource		= src
		mProcessManager	= pmgr
	}

	open override func loadViewContext(rootView root: KCRootView) -> KCSize? {
		guard let src = mSource else {
			CNLog(logLevel: .error, message: "No source file")
			return nil
		}

		guard let procmgr = mProcessManager else {
			CNLog(logLevel: .error, message: "No process manager")
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
				CNLog(logLevel: .error, message: "Failed to load main view")
				return nil
			}
		case .subView(let res, let name):
			if let scr = res.loadSubview(identifier: name) {
				script		= scr
				resource	= res
			} else {
				CNLog(logLevel: .error, message: "Failed to load sub view named: \(name)")
				return nil
			}
		}
		mResource = resource

		let terminfo = CNTerminalInfo(width: 80, height: 25)
		let console  = CNFileConsole()
		let config   = KEConfig(applicationType: .window, doStrict: true, logLevel: .defaultLevel)

		/* Allocate the view state */
		let viewstate = KMViewState(context: context, viewController: self)
		mViewState = viewstate

		/* Compile library */
		let libcompiler = KLCompiler()
		guard libcompiler.compileBase(context: mContext, terminalInfo: terminfo, environment: mEnvironment, console: console, config: config) else {
			console.error(string: "Failed to compile base")
			return nil
		}
		guard libcompiler.compileLibrary(context: mContext, resource: resource, processManager: procmgr, environment: mEnvironment, console: console, config: config) else {
			console.error(string: "Failed to compile library")
			return nil
		}

		/* Compile the Amber script */
		let ambparser = AMBParser()
		let frame: AMBFrame
		switch ambparser.parse(source: script as String) {
		case .ok(let frm):
			frame = frm
		case .error(let err):
			console.error(string: "Error: \(err.toString())")
			return nil
		@unknown default:
			console.error(string: "Error: Unknown switch condition (1)")
			return nil
		}

		/* Allocate the component */
		let ambcompiler = KMComponentCompiler()
		let topcomp: AMBComponent
		switch ambcompiler.compile(frame: frame, context: mContext, processManager: procmgr, environment: mEnvironment) {
		case .ok(let comp):
			topcomp = comp
		case .error(let err):
			console.error(string: "Error: \(err.toString())")
			return nil
		@unknown default:
			console.error(string: "Error: Unknown switch condition (2)")
			return nil
		}

		/* Compile library for component*/
		let alibcompiler = KMLibraryCompiler()
		guard alibcompiler.compile(context: mContext, viewController: self, resource: resource, processManager: procmgr, console: console, environment: mEnvironment, config: config) else {
			console.error(string: "Error: Failed to compile")
			return nil
		}

		/* Setup root view*/
		if let view = topcomp as? KCView {
			root.setup(childView: view)
		} else {
			console.error(string: "Component is NOT view")
		}
		return root.fittingSize
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
			}
			mDidAlreadyLinked = true
		}
	}
}
