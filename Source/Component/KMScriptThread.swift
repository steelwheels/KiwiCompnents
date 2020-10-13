/**
 * @file	KMScriptThread.swift
 * @brief	Define KMScriptThread class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiEngine
import KiwiShell
import CoconutData
import Amber
import Foundation

public protocol KMProcessComponent {
	var isRunning: Bool { get }
}

public class KMScriptThread: AMBComponentObject, KMProcessComponent {
	public static let	IsRunningItem		= "isRunning"

	public var isRunning: Bool

	public override init() {
		isRunning		= false
		super.init()
	}

	public override func setup(reactObject robj: AMBReactObject, context ctxt: KEContext, processManager pmgr: CNProcessManager, environment env: CNEnvironment) -> NSError? {
		if let err = super.setup(reactObject: robj, context: ctxt, processManager: pmgr, environment: env) {
			return err
		}

		robj.set(key: KMScriptThread.IsRunningItem, booleanValue: self.isRunning)

		return nil
	}
}
