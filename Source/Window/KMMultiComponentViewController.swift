/**
 * @file	KMMultiComponentViewController.swift
 * @brief	Define KMMultiComponentViewController class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiControls
import KiwiEngine
import CoconutData
import Foundation

open class KMMultiComponentViewController: KCMultiViewController
{
	private var mResource	    = KEResource(baseURL: Bundle.main.bundleURL)
	private var mProcessManager = CNProcessManager()

	public var processManager: CNProcessManager { get { return mProcessManager }}

	@objc required dynamic public init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	public func pushViewController(script scr: String) {
		let viewctrl = KMComponentViewController(parentViewController: self)
		viewctrl.setup(script: scr, resource: mResource, processManager: mProcessManager)
		super.pushViewController(viewController: viewctrl)
	}
}

