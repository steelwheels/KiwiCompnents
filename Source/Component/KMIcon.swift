/**
 * @file	KMIcon.swift
 * @brief	Define KMIcon class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
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

public class KMIcon: KCIconView, AMBComponent
{
	private static let ImageItem		= "image"
	private static let TitleItem		= "title"
	private static let PressedItem		= "pressed"
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

		/* Add callbacks */
		self.buttonPressedCallback = {
			() -> Void in
			if let evtval = robj.immediateValue(forProperty: KMIcon.PressedItem) {
				CNExecuteInUserThread(level: .event, execute: {
					evtval.call(withArguments: [robj])	// insert self
				})
			}
		}

		/* image */
		addScriptedProperty(object: robj, forProperty: KMIcon.ImageItem)
		if let name = robj.stringValue(forProperty: KMIcon.ImageItem) {
			setIcon(byName: name, console: cons)
		} else {
			robj.setStringValue(value: "", forProperty: KMIcon.ImageItem)
		}
		robj.addObserver(forProperty: KMIcon.ImageItem, callback: {
			(_ param: Any) -> Void in
			if let name = robj.stringValue(forProperty: KMIcon.ImageItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					self.setIcon(byName: name, console: cons)
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMIcon.ImageItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMIcon.ImageItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* title */
		addScriptedProperty(object: robj, forProperty: KMIcon.TitleItem)
		if let ttl = robj.stringValue(forProperty: KMIcon.TitleItem) {
			self.title = ttl
		} else {
			robj.setStringValue(value: "Untitled", forProperty: KMIcon.TitleItem)
		}
		robj.addObserver(forProperty: KMIcon.TitleItem, callback: {
			(_ param: Any) -> Void in
			if let ttl = robj.stringValue(forProperty: KMIcon.TitleItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					super.title = ttl
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMIcon.TitleItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMIcon.TitleItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* scale */
		addScriptedProperty(object: robj, forProperty: KMIcon.ScaleItem)
		if let sclval = robj.floatValue(forProperty: KMIcon.ScaleItem) {
			self.scale = CGFloat(sclval)
		} else {
			robj.setFloatValue(value: 1.0, forProperty: KMIcon.ScaleItem)
		}
		robj.addObserver(forProperty: KMIcon.ScaleItem, callback: {
			(_ param: Any) -> Void in
			if let sclval = robj.floatValue(forProperty: KMIcon.ScaleItem) {
				CNExecuteInMainThread(doSync: false, execute: {
					super.scale = CGFloat(sclval)
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMIcon.ScaleItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMIcon.ScaleItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		return nil
	}

	private func setIcon(byName name: String, console cons: CNConsole) {
		if let img = reactObject.resource.loadImage(identifier: name) {
			super.image = img
		} else {
			cons.error(string: "Failed to load image named: \(name)\n")
		}
	}

	public var children: Array<AMBComponent> { get { return [] }}

	public func addChild(component comp: AMBComponent) {
		CNLog(logLevel: .error, message: "Can not add child components to Button component")
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(icon: self)
	}
}

