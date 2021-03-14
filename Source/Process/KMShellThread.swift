/**
 * @file	KMShellThread.swift
 * @brief	Define KMShellThread class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiShell
import KiwiEngine
import CoconutData
import Foundation

public class KMShellThread: KHShellThread
{
	private var mViewController:	KMComponentViewController

	public init(viewController vcont: KMComponentViewController, processManager procmgr: CNProcessManager, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, environment env: CNEnvironment, config conf: KEConfig) {
		mViewController = vcont
		super.init(processManager: procmgr, input: instrm, output: outstrm, error: errstrm, environment: env, config: conf)
	}

	public override func compile(context ctxt: KEContext, resource res: KEResource, processManager procmgr: CNProcessManager, terminalInfo terminfo: CNTerminalInfo, environment env: CNEnvironment, console cons: CNFileConsole, config conf: KEConfig) -> Bool {
		let libcompiler = KMLibraryCompiler(viewController: mViewController)
		if libcompiler.compile(context: ctxt, resource: res, processManager: procmgr, terminalInfo: terminfo, environment: env, console: cons, config: conf) {
			let shellcompiler = KHShellCompiler()
			return shellcompiler.compile(context: ctxt, resource: res, processManager: procmgr, terminalInfo: terminfo, console: cons, environment: env, config: conf)
		} else {
			return false
		}
	}
}

