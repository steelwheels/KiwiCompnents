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
	private var mReturnValue: CNNativeValue		= .nullValue
	private var mContextStack			= CNStack<Context>()

	public var resource: KEResource? { get { return mResource }}
	public var processManager: CNProcessManager { get { return mProcessManager }}
	public var returnValue: CNNativeValue { get { return mReturnValue }}

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

	public func pushViewController(sourceURL surl: URL, context ctxt: KEContext?) {
		let viewctrl = KMComponentViewController(parentViewController: self)
		viewctrl.setup(sourceURL: surl, processManager: mProcessManager)
		if let c = ctxt {
			mContextStack.push(.context(c))
		} else {
			mContextStack.push(.none)
		}
		super.pushViewController(viewController: viewctrl)
	}

	public func popViewController() -> KEContext? {
		if super.popViewController() {
			if let ctxt = mContextStack.pop() {
				let result: KEContext?
				switch ctxt {
				case .context(let ctxt):	result = ctxt
				case .none:			result = nil
				}
				return result
			} else {
				CNLog(logLevel: .error, message: "Failed to pop stack")
			}
		} else {
			CNLog(logLevel: .error, message: "Failed to pop view")
		}
		return nil
	}

	public func setReturnValue(value val: CNNativeValue) {
		mReturnValue = val
	}
}

