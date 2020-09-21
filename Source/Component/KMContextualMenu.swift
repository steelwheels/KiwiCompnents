/**
 * @file	KMContextualMenu.swift
 * @brief	Define KMContextualMenu class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)

import KiwiControls
import CoconutData
import Foundation

public class KMPopupMenu: KCContextualMenu, KMComponent
{
	private typealias MenuItem = KCContextualMenu.MenuItem

	private var mInputConnection:	KMConnection? = nil
	private var mOutputConnection:	KMConnection? = nil

	public func connect(script scr: CNNativeValue, input inconn: KMConnection, output outconn: KMConnection) -> KMParseError {
		mInputConnection	= inconn
		mOutputConnection	= outconn

		inconn.receiver = self
		outconn.sender  = self

		do {
			let labels = try decode(script: scr)
			super.add(menuItems: labels)
			return .noError
		} catch let err as KMParseError {
			return err
		} catch {
			return .unknownError
		}
	}

	private func decode(script scr: CNNativeValue) throws -> Array<MenuItem> {
		var items: Array<MenuItem> = []
		try scr.checkClassName(requiredClass: KMClass.contextualMenu)

		if let contents = scr.arrayProperty(identifier: "contents") {
			for val in contents {
				let item = try decode(object: val)
				items.append(item)
			}
		} else {
			throw KMParseError.noProperty("contents")
		}
		return items
	}

	private func decode(object obj: CNNativeValue) throws -> MenuItem {
		if let mid = obj.numberProperty(identifier: "id") {
			if let mlabel = obj.stringProperty(identifier: "label") {
				return MenuItem(index: mid.intValue, label: mlabel)
			} else {
				throw KMParseError.noProperty("label")
			}
		} else {
			throw KMParseError.noProperty("id")
		}
	}

	public func receive(data dat: CNNativeValue) {
		NSLog("This compnent does not support receive operation")
	}
}

#endif // os(OSX)
