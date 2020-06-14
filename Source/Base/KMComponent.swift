/**
 * @file	KMComponent.swift
 * @brief	Define KMComponent protocol
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData

public protocol KMComponent
{
	func connect(script scr: CNNativeValue, input inconn: KMConnection, output outconn: KMConnection) -> KMParseError
	func receive(data dat: CNNativeValue)
}

public class KMConnection
{
	public var sender:	KMComponent?
	public var receiver:	KMComponent?

	public init() {
		sender		= nil
		receiver	= nil
	}

	public func send(data dat: CNNativeValue) {
		if let recv = receiver {
			recv.receive(data: dat)
		}
	}
}
