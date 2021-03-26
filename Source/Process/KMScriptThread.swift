/**
 * @file	KMScriptThread.swift
 * @brief	Define KMScriptThread class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import KiwiShell
import KiwiEngine
import KiwiLibrary
import CoconutData
import Foundation

public class KMScriptThread: KHScriptThread
{
	private var mViewController: KMComponentViewController

	public init(viewController vcont: KMComponentViewController, source src: KLSource, processManager procmgr: CNProcessManager, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, environment env: CNEnvironment, config conf: KEConfig) {
		mViewController = vcont
		super.init(source: src, processManager: procmgr, input: instrm, output: outstrm, error: errstrm, environment: env, config: conf)
	}

	public override func compile(context ctxt: KEContext, resource res: KEResource, processManager procmgr: CNProcessManager, terminalInfo terminfo: CNTerminalInfo, environment env: CNEnvironment, console cons: CNFileConsole, config conf: KEConfig) -> Bool {
		var result = false
		if super.compile(context: ctxt, resource: res, processManager: procmgr, terminalInfo: terminfo, environment: env, console: cons, config: conf) {
			let ambcompiler = AMBLibraryCompiler()
			if ambcompiler.compile(context: ctxt, resource: res, processManager: procmgr, environment: env, console: cons, config: conf) {
				let compiler = KMLibraryCompiler(viewController: mViewController)
				result = compiler.compile(context: ctxt, resource: res, processManager: procmgr, terminalInfo: terminfo, environment: env, console: cons, config: conf)
			}
		}
		return result
	}
}

