/**
 * @file	KMShellThread.swift
 * @brief	Define KMShellThread class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiShell
import Amber
import KiwiLibrary
import KiwiEngine
import CoconutData
import Foundation

public class KMShellThread: KHShellThread
{
	private var mViewController:	KMComponentViewController

	public init(viewController vcont: KMComponentViewController, processManager procmgr: CNProcessManager, input ifile: CNFile, output ofile: CNFile, error efile: CNFile, terminalInfo terminfo: CNTerminalInfo, environment env: CNEnvironment, config conf: KEConfig) {
		mViewController = vcont
		super.init(processManager: procmgr, input: ifile, output: ofile, error: efile, terminalInfo: terminfo, environment: env, config: conf)
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

