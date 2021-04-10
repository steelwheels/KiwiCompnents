/**
 * @file	KMThreadLauncher.swift
 * @brief	Define KMThreadLauncher class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiShell
import KiwiLibrary
import KiwiEngine
import CoconutData
import Foundation

public class KMThreadLauncher: KLThreadLauncher
{
	private var mViewController: KMComponentViewController

	public init(viewController vcont: KMComponentViewController, context ctxt: KEContext, resource res: KEResource, processManager procmgr: CNProcessManager, terminalInfo terminfo: CNTerminalInfo, environment env: CNEnvironment, config conf: KEConfig) {
		mViewController = vcont
		super.init(context: ctxt, resource: res, processManager: procmgr, terminalInfo: terminfo, environment: env, config: conf)
	}

	open override func allocateThread(source src: KLSource, processManager procmgr: CNProcessManager, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, terminalInfo terminfo: CNTerminalInfo, environment env: CNEnvironment, config conf: KEConfig) -> KLThread {
		let result = KMScriptThread(viewController: mViewController, source: src, processManager: procmgr, input: instrm, output: outstrm, error: errstrm, terminalInfo: terminfo, environment: env, config: conf)
		return result
	}
}
