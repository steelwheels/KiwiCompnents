/**
 * @file	KMTerminalView.swift
 * @brief	Define KMTerminalView class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiControls
import Amber
import KiwiEngine
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMTerminalView: KCTerminalView, AMBComponent
{
	private var mReactObject:	AMBReactObject?
	private var mContext:		KEContext?
	private var mEnvironment:	CNEnvironment?
	private var mChildComponents:	Array<AMBComponent>

	public var reactObject: AMBReactObject	{ get { getProperty(mReactObject) 	}}
	public var context: KEContext		{ get { getProperty(mContext) 		}}
	public var environment: CNEnvironment	{ get { getProperty(mEnvironment)	}}

	public init(){
		mReactObject		= nil
		mContext		= nil
		mEnvironment		= nil
		mChildComponents	= []
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 480, height: 270)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 375, height: 22)
		#endif
		super.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		mReactObject		= nil
		mContext		= nil
		mEnvironment		= nil
		mChildComponents	= []
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, context ctxt: KEContext, processManager pmgr: CNProcessManager, environment env: CNEnvironment) -> NSError? {
		mReactObject	= robj
		mContext	= ctxt
		return nil
	}

	public var children: Array<AMBComponent> { get { return mChildComponents }}

	public func addChild(component comp: AMBComponent) {
		if mChildComponents.count == 0 {
			if let shell = comp as? KMShell {
				mChildComponents.append(shell)
			} else {
				CNLog(logLevel: .error, message: "The terminal view can have shell component only")
			}
		} else {
			CNLog(logLevel: .error, message: "The terminal view can have ONLY one child")
		}
	}

	public func startShell(viewController vcont: KMComponentViewController, resource res: KEResource) {
		for child in mChildComponents {
			if let shell = child as? KMShell {
				let instrm:  CNFileStream = .fileHandle(self.inputFileHandle )
				let outstrm: CNFileStream = .fileHandle(self.outputFileHandle)
				let errstrm: CNFileStream = .fileHandle(self.errorFileHandle )
				shell.start(viewController: vcont, inputStream: instrm, outputStream: outstrm, errorStream: errstrm, resource: res)
			}
		}
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(terminalView: self)
	}

	public func toText() -> CNTextSection {
		return reactObject.toText()
	}
}

