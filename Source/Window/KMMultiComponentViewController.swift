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
	private var mResource: KEResource?	= nil
	private var mProcessManager		= CNProcessManager()

	public var processManager: CNProcessManager { get { return mProcessManager }}

	@objc required dynamic public init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	open override func viewDidLoad() {
		mResource = loadResource()
		super.viewDidLoad()
	}

	open func loadResource() -> KEResource {
		return KEResource(baseURL: Bundle.main.bundleURL)
	}

	public func pushViewController(viewName vname: String) {
		guard let resource = mResource else {
			CNLog(logLevel: .error, message: "Can not happen. Resource is NOT loaded")
			return
		}
		let viewctrl = KMComponentViewController(parentViewController: self)
		viewctrl.setup(viewName: vname, resource: resource, processManager: mProcessManager)
		super.pushViewController(viewController: viewctrl)
	}
}

