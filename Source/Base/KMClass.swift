/**
 * @file	KMClass.swift
 * @brief	Define KMClass protocol
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Foundation

public enum KMClass: String {
	case contextualMenu		= "ContextualMenu"
}

/*
extension KMValue
{
	public var stringValue: String? {
		get {
			switch self {
			case .string(let str):	return str
			default:		return nil
			}
		}
	}
}

extension KMObject
{
	

	public func checkClass(requiredClass reqcls: KMClass) throws {
		if let val = self.get(indeitifier: "class") {
			if let name = val.stringValue {
				if let curcls = KMClass(rawValue: name) {
					if curcls == reqcls {
						return
					} else {
						throw KMParseError.unexpectedClassName(name)
					}
				} else {
					throw KMParseError.unknownClassName(name)
				}
			}
		}
		throw KMParseError.noClassName
	}

	public func anyValue(propertyName propname: String) throws -> KMValue {
		if let val = self.get(indeitifier: propname) {
			return val
		} else {
			throw KMParseError.noProperty(propname)
		}
	}

	public func intValue(propertyName propname: String) throws -> Int {
		switch try anyValue(propertyName: propname) {
		case .int(let val):	return val
		default:		throw KMParseError.unexpectedPropertyValue(propname)
		}
	}

	public func stringValue(propertyName propname: String) throws -> String {
		switch try anyValue(propertyName: propname) {
		case .string(let val):	return val
		default:		throw KMParseError.unexpectedPropertyValue(propname)
		}
	}
}
*/

