/**
 * @file	KMCompiler.swift
 * @brief	Define KMCompiler protocol
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiShell
import KiwiLibrary
import KiwiEngine
import CoconutData
import Foundation

public class KMComponentCompiler: KHExternalCompiler
{
	public init() {
		
	}

	public func compile(context ctxt: KEContext, config conf: KEConfig) -> Bool {
		return true
	}
}
