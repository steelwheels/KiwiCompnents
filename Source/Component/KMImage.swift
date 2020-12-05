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
	static let NameItem = "name"

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

	public func setup(reactObject robj: AMBReactObject) -> NSError? {
		mReactObject	= robj

		/* Sync initial value: name */
		if let name = robj.stringValue(forProperty: KMImage.NameItem) {
			setImage(byName: name)
		} else {
			robj.setStringValue(string: "", forProperty: KMImage.NameItem)
		}

		/* Add listner: isEnabled */
		robj.addObserver(forProperty: KMImage.NameItem, callback: {
			(_ param: Any) -> Void in
			if let name = robj.stringValue(forProperty: KMImage.NameItem) {
				self.setImage(byName: name)
			} else {
				NSLog("No name for image")
			}
		})

		return nil
	}

	private func setImage(byName name: String) {
		if let img = reactObject.resource.loadImage(identifier: name) {
			super.set(image: img)
		}
	}

	public var children: Array<AMBComponent> { get { return [] }}

	public func addChild(component comp: AMBComponent) {
		NSLog("Can not add child components to Button component")
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(image: self)
	}
}

