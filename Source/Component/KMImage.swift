/**
 * @file	KMImage.swift
 * @brief	Define KMImage class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation
import KiwiControls
import Amber
import KiwiEngine
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMImage: KCImageView, AMBComponent
{
	private static let NameItem 		= "name"
	private static let ScaleItem		= "scale"

	private var mReactObject:	AMBReactObject?

	public var reactObject: AMBReactObject	{ get {
		if let robj = mReactObject {
			return robj
		} else {
			fatalError("No react object")
		}
	}}

	public init() {
		mReactObject	= nil
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 50, height: 50)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 50)
		#endif
		super.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		mReactObject	= nil
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj

		/* Sync initial value: name */
		if let name = robj.stringValue(forProperty: KMImage.NameItem) {
			setImage(byName: name, console: cons)
		} else {
			robj.setStringValue(value: "", forProperty: KMImage.NameItem)
		}
		/* Add listner: name */
		robj.addObserver(forProperty: KMImage.NameItem, callback: {
			(_ param: Any) -> Void in
			if let name = robj.stringValue(forProperty: KMImage.NameItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					self.setImage(byName: name, console: cons)
				})
			} else {
				cons.error(string: "No name to load image\n")
			}
		})

		/* Sync initial value: scale */
		if let scale = robj.floatValue(forProperty: KMImage.ScaleItem) {
			self.scale = CGFloat(scale)
		} else {
			robj.setFloatValue(value: Double(self.scale), forProperty: KMImage.ScaleItem)
		}
		/* Add listner: scale */
		robj.addObserver(forProperty: KMImage.ScaleItem, callback: {
			(_ param: Any) -> Void in
			if let scale = robj.floatValue(forProperty: KMImage.ScaleItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					self.scale = CGFloat(scale)
				})
			} else {
				cons.error(string: "No scale for image\n")
			}
		})

		return nil
	}

	private func setImage(byName name: String, console cons: CNConsole) {
		if let img = reactObject.resource.loadImage(identifier: name) {
			super.set(image: img)
		} else {
			cons.error(string: "Failed to load image named: \(name)\n")
		}
	}

	public var children: Array<AMBComponent> { get { return [] }}

	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Can not add child components to Button component")
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(image: self)
	}
}

