/**
 * @file	KMObjectDumper.swift
 * @brief	Define KMObjectDumper class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

public class KMObjectDumper
{
	public init() {
	}

	public func dump(object obj: KMObject) -> CNTextSection {
		let sect = CNTextSection()
		sect.header = "{" ; sect.footer = "}"
		for (ident, val) in obj.properties {
			let txt = dump(identifier: ident, value: val)
			sect.add(text: txt)
		}
		return sect
	}

	public func dump(identifier ident: String, value val: KMValue) -> CNText {
		let valtxt = dump(value: val)
		if let valsect = valtxt as? CNTextSection {
			valsect.header = "\(ident) : " + valsect.header
			return valsect
		} else if let valline = valtxt as? CNTextLine {
			return CNTextLine(string: "\(ident) : " + valline.string)
		} else {
			fatalError("\(#file): Unknown object")
		}
	}

	public func dump(value val: KMValue) -> CNText {
		let result: CNText
		switch val {
		case .bool(let val):	result = CNTextLine(string: "\(val)")
		case .int(let val):	result = CNTextLine(string: "\(val)")
		case .float(let val):	result = CNTextLine(string: "\(val)")
		case .string(let val):	result = CNTextLine(string: val)
		case .null:		result = CNTextLine(string: "null")
		case .object(let obj):	result = dump(object: obj)
		case .text(let val):
			let sect = CNTextSection()
			sect.header = "%{" ; sect.footer = "%}"
			sect.addMultiLines(string: val)
			result = sect
		case .array(let vals):
			let sect = CNTextSection()
			sect.header = "[" ; sect.footer = "]"
			for val in vals {
				let txt = dump(value: val)
				sect.add(text: txt)
			}
			result = sect
		}
		return result
	}
}

