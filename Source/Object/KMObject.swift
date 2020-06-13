/**
 * @file	KMObject.swift
 * @brief	Define KMObject data structure
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

public enum KMValue {
	case bool(Bool)
	case int(Int)
	case float(Double)
	case string(String)
	case text(String)
	case object(KMObject)
	case array(Array<KMValue>)
	case null

	public func dump() -> CNText {
		let result: CNText
		switch self {
		case .bool(let val):	result = CNTextLine(string: "\(val)")
		case .int(let val):	result = CNTextLine(string: "\(val)")
		case .float(let val):	result = CNTextLine(string: "\(val)")
		case .string(let val):	result = CNTextLine(string: "\(val)")
		case .text(let val):	result = CNTextLine(string: "\(val)")
		case .null:		result = CNTextLine(string: "null")
		case .object(let obj):
			let dumper = KMObjectDumper()
			result = dumper.dump(object: obj)
		case .array(let values):
			let sect = CNTextSection()
			sect.header = "[" ; sect.footer = "]"
			for val in values {
				sect.add(text: val.dump())
			}
			result = sect
		}
		return result
	}
}

public class KMObject
{
	private var mProperties: Dictionary<String, KMValue>

	public var properties: Dictionary<String, KMValue> { get { return mProperties }}

	public init() {
		mProperties = [:]
	}

	public func set(identifier ident: String, value val: KMValue) {
		mProperties[ident] = val
	}

	public func get(indeitifier ident: String) -> KMValue? {
		return mProperties[ident]
	}
}

