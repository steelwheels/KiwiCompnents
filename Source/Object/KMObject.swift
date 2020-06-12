/**
 * @file	KMObject.swift
 * @brief	Define KMObject data structure
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

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

