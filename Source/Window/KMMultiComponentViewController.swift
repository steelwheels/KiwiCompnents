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
	private enum Context {
		case	context(KEContext)
		case	none
	}

	private var mResource: KEResource?		= nil
	private var mProcessManager			= CNProcessManager()

	public var resource: KEResource? { get { return mResource }}
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

	public func pushViewController(source src: KMSource) {
		let viewctrl = KMComponentViewController(parentViewController: self)
		viewctrl.setup(source: src, processManager: mProcessManager)
		super.pushViewController(viewController: viewctrl)
	}

	public func popViewController(returnValue retval: CNNativeValue) -> Bool {
		if super.popViewController() {
			if let curview = super.currentViewController() as? KMComponentViewController {
				curview.state.setReturnValue(value: retval)
			} else {
				NSLog("Error: Unexpected object")
			}
			return true
		} else {
			return false
		}
	}
}

