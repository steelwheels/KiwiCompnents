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
