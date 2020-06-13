/**
 * @file	KMContextualMenu.swift
 * @brief	Define KMContextualMenu class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiControls
import Foundation

public class KMPopupMenu: KCContextualMenu, KMComponent
{
	private typealias MenuItem = KCContextualMenu.MenuItem

	private var mInputConnection:	KMConnection? = nil
	private var mOutputConnection:	KMConnection? = nil

	public func connect(script scr: KMObject, input inconn: KMConnection, output outconn: KMConnection) -> KMParseError {
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

	private func decode(script scr: KMObject) throws -> Array<MenuItem> {
		var items: Array<MenuItem> = []
		try scr.checkClass(requiredClass: KMClass.contextualMenu)
		if let contents = scr.get(indeitifier: "contents") {
			switch contents {
			case .array(let values):
				for val in values {
					switch val {
					case .object(let obj):
						let item = try decode(object: obj)
						items.append(item)
					default:
						throw KMParseError.unexpectedValue(val)
					}
				}
			default:
				throw KMParseError.unexpectedPropertyValue("contents")
			}
		} else {
			throw KMParseError.noProperty("contents")
		}
		return items
	}

	private func decode(object obj: KMObject) throws -> MenuItem {
		let mid    = try obj.intValue(propertyName: "id")
		let mlabel = try obj.stringValue(propertyName: "label")
		return MenuItem(index: mid, label: mlabel)
	}

	public func receive(data dat: KMObject) {
		NSLog("This compnent does not support receive operation")
	}
}

