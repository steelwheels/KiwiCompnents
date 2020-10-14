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
	public static let SourceFileVariableName = "SRCFILE"

	private var mShellThread:	KHShellThread?
	private var mScriptThread:	KHScriptThread?

	public override init() {
		mShellThread	= nil
		mScriptThread	= nil
		super.init()
	}

	public func start(inputStream instrm: CNFileStream, outputStream outstrm: CNFileStream, errorStream errstrm: CNFileStream) {
		let env = self.environment
		if let srcfile = env.getString(name: KMShell.SourceFileVariableName) {
			if let url = URL(string: srcfile) {
				NSLog("URL=\(url.absoluteString)")
				let src: KESourceFile = .file(url)
				startScript(sourceFile: src, inputStream: instrm, outputStream: outstrm, errorStream: errstrm)
			} else {
				/* Failed to get source file */
				startShell(inputStream: instrm, outputStream: outstrm, errorStream: errstrm)
			}
		} else {
			/* No startup source file */
			startShell(inputStream: instrm, outputStream: outstrm, errorStream: errstrm)
		}
	}

	private func startShell(inputStream instrm: CNFileStream, outputStream outstrm: CNFileStream, errorStream errstrm: CNFileStream) {
		setupEnvironment(environment: self.environment)
		let conf = KEConfig(applicationType: .window, doStrict: true, logLevel: .defaultLevel)
		let thread = KHShellThread(processManager: self.processManager, input: instrm, output: outstrm, error: errstrm, environment: self.environment, config: conf)
		thread.start(argument: .nullValue)
		mShellThread = thread
	}

	private func startScript(sourceFile src: KESourceFile, inputStream instrm: CNFileStream, outputStream outstrm: CNFileStream, errorStream errstrm: CNFileStream) {
		setupEnvironment(environment: self.environment)
		let conf   = KHConfig(applicationType: .window, hasMainFunction: true, doStrict: true, logLevel: .warning)
		let thread = KHScriptThread(sourceFile: src, processManager: self.processManager, input: instrm, output: outstrm, error: errstrm, environment: environment, config: conf)
		thread.start(argument: .nullValue)
		mScriptThread = thread
	}

	private func setupEnvironment(environment env: CNEnvironment) {
		env.set(name: "TERM",           value: .stringValue("xterm-16color"))
		env.set(name: "CLICOLOR",       value: .stringValue("1"))
		env.set(name: "CLICOLOR_FORCE", value: .stringValue("1"))
	}
}

