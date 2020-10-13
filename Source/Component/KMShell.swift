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
	private var mThread:	KHShellThread?

	public override init() {
		mThread	= nil
		super.init()
	}

	public func start(inputStream instrm: CNFileStream, outputStream outstrm: CNFileStream, errorStream errstrm: CNFileStream) {
		let conf = KEConfig(applicationType: .window, doStrict: true, logLevel: .defaultLevel)
		let thread = KHShellThread(processManager: self.processManager, input: instrm, output: outstrm, error: errstrm, environment: self.environment, config: conf)
		thread.start(argument: .nullValue)
		mThread = thread
	}
}

