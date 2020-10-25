/**
 * @file	KMScriptThread.swift
 * @brief	Define KMScriptThread class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import KiwiShell
import KiwiEngine
import CoconutData
import Foundation

public class KMScriptThread: KHScriptThread
{
	private var mRootViewController:	KMMultiComponentViewController

	public init(rootViewController root: KMMultiComponentViewController, threadName thname: String?, resource res: KEResource, processManager procmgr: CNProcessManager, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, environment env: CNEnvironment, config conf: KHConfig) {
		mRootViewController = root
		super.init(threadName: thname, resource: res, processManager: procmgr, input: instrm, output: outstrm, error: errstrm, environment: env, config: conf)
	}

	public init(rootViewController root: KMMultiComponentViewController, scriptURL scrurl: URL, processManager procmgr: CNProcessManager, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, environment env: CNEnvironment, config conf: KEConfig) {
		mRootViewController = root
		super.init(scriptURL: scrurl, processManager: procmgr, input: instrm, output: outstrm, error: errstrm, environment: env, config: conf)
	}

	public override func compile(context ctxt: KEContext, resource res: KEResource, processManager procmgr: CNProcessManager, terminalInfo terminfo: CNTerminalInfo, environment env: CNEnvironment, console cons: CNFileConsole, config conf: KEConfig) -> Bool {
		if super.compile(context: ctxt, resource: res, processManager: procmgr, terminalInfo: terminfo, environment: env, console: cons, config: conf) {
			let compiler = KMLibraryCompiler()
			if let err = compiler.compile(context: ctxt, multiComponentViewController: mRootViewController, environment: env) {
				cons.error(string: "[Error] \(err.toString())")
			} else {
				return true
			}
		}
		return false
	}
}

