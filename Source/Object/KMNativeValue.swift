/**
 * @file	KMNativeValue.swift
 * @brief	Extend CNNativeValue class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData

public enum KMParseError: Error {
	case noError
	case unknownError
	case noClassName
	case unknownClassName(String)		// class name
	case unexpectedClassName(String)	// class name
	case noProperty(String)			// property name
	case unexpectedPropertyValue(String)	// property name
	case unexpectedValue(CNNativeValue)

	public var description: String {
		get {
			let result: String
			switch self {
			case .noError:				result = "No error"
			case .unknownError:			result = "Unknown error"
			case .noClassName:			result = "No class name"
			case .unknownClassName(let name):	result = "Unknown class name: \(name)"
			case .unexpectedClassName(let name):	result = "Unexpected class name: \(name)"
			case .noProperty(let name):		result = "Property is not found: \(name)"
			case .unexpectedPropertyValue(let val):	result = "Property \(val) has unexpected value"
			case .unexpectedValue(_):		result = "Unexpected property value"
			}
			return result
		}
	}
}

extension CNNativeValue
{
	public var className: String? {
		get {
			var result: String? = nil
			if let dict = self.toDictionary() {
				if let val = dict["class"] {
					result = val.toString()
				}
			}
			return result
		}
	}

	public func checkClassName(requiredClass reqcls: KMClass) throws {
		if let name = self.className {
			if name == reqcls.rawValue {
				return
			} else {
				throw KMParseError.unknownClassName(name)
			}
		} else {
			throw KMParseError.noClassName
		}
	}
}

