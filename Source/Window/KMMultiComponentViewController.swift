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

	public func pushViewController(source src: KMSource) -> KMViewState {
		let viewctrl = KMComponentViewController(parentViewController: self)
		viewctrl.setup(source: src, processManager: mProcessManager)
		super.pushViewController(viewController: viewctrl)
		return viewctrl.state
	}

	public func popViewController(returnValue retval: CNNativeValue) -> Bool {
		/* Set return value */
		if let view = super.currentViewController() as? KMComponentViewController {
			view.state.setReturnValue(value: retval)
		} else {
			NSLog("No view to return the value")
		}
		/* Pop the view */
		return super.popViewController()
	}
}

