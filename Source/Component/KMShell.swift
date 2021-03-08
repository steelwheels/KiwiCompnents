/**
 * @file	KMShell.swift
 * @brief	Define KMShell class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiShell
import KiwiEngine
import Amber
import CoconutData
import Foundation

public class KMShell: AMBComponentObject
{
	static let ScriptItem		= "script"

	private var mShellThread:	KHShellThread?
	private var mScriptThread:	KHScriptThread?

	public override init() {
		mShellThread	= nil
		mScriptThread	= nil
		super.init()
	}

	public func start(viewController vcont: KMComponentViewController, inputStream instrm: CNFileStream, outputStream outstrm: CNFileStream, errorStream errstrm: CNFileStream, resource res: KEResource) {
		if let srcname = reactObject.stringValue(forProperty: KMShell.ScriptItem) {
			if let url = res.URLOfThread(identifier: srcname) {
				let res = KEResource(singleFileURL: url)
				startScript(viewController: vcont, resource: res, inputStream: instrm, outputStream: outstrm, errorStream: errstrm)
			} else {
				/* Failed to get source file */
				CNLog(logLevel: .error, message: "Failed to load scripte source: \(srcname)")
				startShell(viewController: vcont, inputStream: instrm, outputStream: outstrm, errorStream: errstrm)
			}
		} else {
			/* No startup source file */
			startShell(viewController: vcont, inputStream: instrm, outputStream: outstrm, errorStream: errstrm)
		}
	}

	private func startShell(viewController vcont: KMComponentViewController, inputStream instrm: CNFileStream, outputStream outstrm: CNFileStream, errorStream errstrm: CNFileStream) {
		setupEnvironment(environment: reactObject.environment)
		let conf = KEConfig(applicationType: .window, doStrict: true, logLevel: .defaultLevel)
		let thread = KMShellThread(viewController: vcont, processManager: reactObject.processManager, input: instrm, output: outstrm, error: errstrm, environment: reactObject.environment, config: conf)
		thread.start(argument: .nullValue)
		mShellThread = thread
	}

	private func startScript(viewController vcont: KMComponentViewController, resource res: KEResource, inputStream instrm: CNFileStream, outputStream outstrm: CNFileStream, errorStream errstrm: CNFileStream) {
		setupEnvironment(environment: reactObject.environment)
		let conf   = KHConfig(applicationType: .window, hasMainFunction: true, doStrict: true, logLevel: .warning)
		let thread = KMScriptThread(viewController: vcont, source: .application(res), processManager: reactObject.processManager, input: instrm, output: outstrm, error: errstrm, environment: reactObject.environment, config: conf)
		thread.start(argument: .nullValue)
		mScriptThread = thread
	}

	private func setupEnvironment(environment env: CNEnvironment) {
		env.set(name: "TERM",           value: .stringValue("xterm-16color"))
		env.set(name: "CLICOLOR",       value: .stringValue("1"))
		env.set(name: "CLICOLOR_FORCE", value: .stringValue("1"))

		let home = CNPreference.shared.userPreference.homeDirectory
		env.setURL(name: "HOME", value: home)
		env.setURL(name: "PWD",  value: home)
	}
}

