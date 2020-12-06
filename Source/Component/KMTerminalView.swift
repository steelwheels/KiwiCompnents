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
	private var mChildComponents:	Array<AMBComponent>

	public var reactObject: AMBReactObject {
		get {
			if let robj = mReactObject {
				return robj
			} else {
				fatalError("No react object")
			}
		}
	}

	public init(){
		mReactObject		= nil
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
		mChildComponents	= []
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj
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
}

