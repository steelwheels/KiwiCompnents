/**
 * @file	KMComponent.swift
 * @brief	Define KMComponent protocol
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

public enum KMParseError: Error {
	case noError
	case unknownError
	case noClassName
	case unknownClassName(String)		// class name
	case unexpectedClassName(String)	// class name
	case noProperty(String)			// property name
	case unexpectedPropertyValue(String)	// property name
	case unexpectedValue(KMValue)

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

public protocol KMComponent
{
	func connect(script scr: KMObject, input inconn: KMConnection, output outconn: KMConnection) -> KMParseError
	func receive(data dat: KMObject)
}

public class KMConnection
{
	public var sender:	KMComponent?
	public var receiver:	KMComponent?

	public init() {
		sender		= nil
		receiver	= nil
	}

	public func send(data dat: KMObject) {
		if let recv = receiver {
			recv.receive(data: dat)
		}
	}
}
