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
	private var mResource: KEResource?		= nil
	private var mProcessManager			= CNProcessManager()
	private var mReturnValue: CNNativeValue		= .nullValue

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

	open func pushViewController(viewName vname: String) {
		guard let resource = mResource else {
			CNLog(logLevel: .error, message: "Can not happen. Resource is NOT loaded")
			return
		}
		let viewctrl = KMComponentViewController(parentViewController: self)
		viewctrl.setup(viewName: vname, resource: resource, processManager: mProcessManager)
		super.pushViewController(viewController: viewctrl)
	}

	public func pushViewController(sourceURL surl: URL) {
		let viewctrl = KMComponentViewController(parentViewController: self)
		viewctrl.setup(sourceURL: surl, processManager: mProcessManager)
		super.pushViewController(viewController: viewctrl)
	}

	public func setReturnValue(value val: CNNativeValue) {
		mReturnValue = val
	}

	public func launchViewController(sourceURL surl: URL) -> CNNativeValue {
		mReturnValue = .nullValue
		self.pushViewController(sourceURL: surl)
		return mReturnValue
	}

	public func launchViewController(viewName vname: String) -> CNNativeValue {
		mReturnValue	= .nullValue
		/* Move to next view */
		self.pushViewController(viewName: vname)
		return mReturnValue
	}
}

