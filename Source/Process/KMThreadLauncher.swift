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
	private var mRootViewController: KMMultiComponentViewController

	public init(rootViewController root: KMMultiComponentViewController, context ctxt: KEContext, resource res: KEResource, processManager procmgr: CNProcessManager, environment env: CNEnvironment, config conf: KEConfig) {
		mRootViewController = root
		super.init(context: ctxt, resource: res, processManager: procmgr, environment: env, config: conf)
	}

	open override func allocateThread(source src: KLSource, processManager procmgr: CNProcessManager, input instrm: CNFileStream, output outstrm: CNFileStream, error errstrm: CNFileStream, environment env: CNEnvironment, config conf: KEConfig) -> KLThread {
		let uconf = updateConfig(config: conf)
		let result = KMScriptThread(rootViewController: mRootViewController, source: src, processManager: procmgr, input: instrm, output: outstrm, error: errstrm, environment: env, config: uconf)
		return result
	}

	private func updateConfig(config conf: KEConfig) -> KHConfig {
		return KHConfig(applicationType: conf.applicationType, hasMainFunction: true, doStrict: conf.doStrict, logLevel: conf.logLevel)
	}
}
