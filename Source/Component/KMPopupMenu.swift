/**
 * @file	KMPopupMenu.swift
 * @brief	Define KMPopupMenu class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiControls
import Foundation

public class KMPopupMenu: KCPopupMenu, KMComponent
{
	private struct MenuItem {
		public var 	menuId:		Int
		public var	menuLabel:	String

		public init(menuId mid: Int, menuLabel mlabel: String) {
			menuId		= mid
			menuLabel	= mlabel
		}
	}

	private var mInputConnection:	KMConnection? = nil
	private var mOutputConnection:	KMConnection? = nil

	public func connect(script scr: KMObject, input inconn: KMConnection, output outconn: KMConnection) -> KMParseError {
		mInputConnection	= inconn
		mOutputConnection	= outconn

		do {
			let labels = try decode(script: scr)
			super.addItems(withTitles: labels)
			return .noError
		} catch let err as KMParseError {
			return err
		} catch {
			return .unknownError
		}
	}

	private func decode(script scr: KMObject) throws -> Array<String> {
		var items: Array<String> = []
		try scr.checkClass(requiredClass: KMClass.popupMenu)
		if let contents = scr.get(indeitifier: "contents") {
			switch contents {
			case .array(let values):
				for val in values {
					switch val {
					case .string(let str):
						items.append(str)
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

	public func receive(data dat: KMObject) {
		NSLog("This compnent does not support receive operation")
	}
}

