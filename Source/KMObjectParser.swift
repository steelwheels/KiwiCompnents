/**
 * @file	KMObjectParser.swift
 * @brief	Define KMObjectParser class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

public class KMObjectParser
{
	public enum Result {
		case ok(KMObject)
		case error(ParseError)
	}

	public enum ParseError: Error {
		case tokenError(CNParseError)
		case unknownError
		case unexpectedEndOfStream
		case unexpectedToken(CNToken, Int)
		case unexpectedSymbol(Character, Character, Int)	// given, required, line

		public var description: String {
			get {
				let result: String
				switch self {
				case .tokenError(let err):	result = err.description()
				case .unknownError:		result = "Unknown error"
				case .unexpectedEndOfStream:	result = "Unexpected end of token"
				case .unexpectedToken(let token, let lineno):
					result = "Unexpected token \"\(token.toString())\" at line \(lineno)"
				case .unexpectedSymbol(let real, let exp, let lineno):
					result = "Char \"\(exp)\" is expected but \"\(real)\" is given at line \(lineno)"
				}
				return result
			}
		}
	}

	public init(){
	}

	public func parse(source src: String) -> Result {
		/* Remove comments in the string */
		let lines = removeComments(lines: src.components(separatedBy: "\n"))
		let msrc  = lines.joined(separator: "\n")
		/* Get tokens from source text*/
		let conf = CNParserConfig(allowIdentiferHasPeriod: false)
		let result: Result
		switch CNStringToToken(string: msrc, config: conf) {
		case .ok(let tokens):
			do {
				if tokens.count > 0 {
					/* Parse object */
					let obj = try parseObject(tokenStream: CNTokenStream(source: tokens))
					result = .ok(obj)
				} else {
					result = .error(.unexpectedEndOfStream)
				}
			} catch let err as ParseError {
				result = .error(err)
			} catch {
				result = .error(.unknownError)
			}
		case .error(let err):
			result = .error(.tokenError(err))
		}
		return result
	}

	private func removeComments(lines lns: Array<String>) -> Array<String> {
		var result: Array<String> = []
		for line in lns {
			let parts = line.components(separatedBy: "//")
			result.append(parts[0])
		}
		return result
	}

	private func parseObject(tokenStream stream: CNTokenStream) throws -> KMObject {
		let result = KMObject()
		try requireSymbol(symbol: "{", in: stream)

		var is1st = true
		parse_loop: while true {
			if let c = checkSymbol(in: stream) {
				if c == "}" {
					break parse_loop
				} else if !is1st && c == "," {
					/* Continue */
				} else {
					/* Ignore */
					let _ = stream.unget()
				}
			}
			if let (ident, val) = try parseProperty(tokenStream: stream) {
				result.set(identifier: ident, value: val)
			} else {
				break parse_loop
			}
			is1st = false
		}
		return result
	}

	private func parseProperty(tokenStream stream: CNTokenStream) throws -> (String, KMValue)? {
		if let ident = checkIdentifier(in: stream) {
			try requireSymbol(symbol: ":", in: stream)
			let value = try parseValue(tokenStream: stream)
			return (ident, value)
		}
		return nil
	}

	public func parseValue(tokenStream stream: CNTokenStream) throws -> KMValue {
		if let token = stream.get() {
			let result: KMValue
			if let c = token.getSymbol() {
				if c == "[" {
					result = try parseArrayValue(tokenStream: stream)
				} else if c == "{" {
					let _   = stream.unget()
					let obj = try parseObject(tokenStream: stream)
					result = .object(obj)
				} else {
					throw ParseError.unexpectedToken(token, token.lineNo)
				}
			} else {
				switch token.type {
				case .BoolToken(let value):	result = .bool(value)
				case .IntToken(let value):	result = .int(value)
				case .UIntToken(let value):	result = .int(Int(value))
				case .DoubleToken(let value):	result = .float(value)
				case .StringToken(let value):	result = .string(value)
				case .TextToken(let value):	result = .text(value)
				default: throw ParseError.unexpectedToken(token, token.lineNo)
				}
			}
			return result
		} else {
			throw ParseError.unexpectedEndOfStream
		}
	}

	public func parseArrayValue(tokenStream stream: CNTokenStream) throws -> KMValue {
		var vals: Array<KMValue> = []
		var is1st = true
		parse_loop: while true {
			if let c = checkSymbol(in: stream) {
				if c == "]" {
					break parse_loop
				} else if c == "," && !is1st {
					/* Continue */
				} else  {
					/* ignore */
					let _ = stream.unget()
				}
			}
			let val = try parseValue(tokenStream: stream)
			vals.append(val)
			is1st = false
		}
		return .array(vals)
	}

	private func requireSymbol(symbol sym: Character, in stream: CNTokenStream) throws {
		if let token = stream.get() {
			if let c = token.getSymbol() {
				if c != sym { throw ParseError.unexpectedSymbol(c, sym, token.lineNo) }
			} else {
				throw ParseError.unexpectedToken(token, token.lineNo)
			}
		} else {
			throw ParseError.unexpectedEndOfStream
		}
	}

	private func checkSymbol(in stream: CNTokenStream) -> Character? {
		if let token = stream.get() {
			if let c = token.getSymbol() {
				return c
			} else {
				let _ = stream.unget()
				return nil
			}
		} else {
			return nil
		}
	}

	private func checkIdentifier(in stream: CNTokenStream) -> String? {
		if let token = stream.get() {
			if let ident = token.getIdentifier() {
				return ident
			} else {
				let _ = stream.unget()
				return nil
			}
		} else {
			return nil
		}
	}

	private func lineNo(tokenStream stream: CNTokenStream) -> Int {
		if let no = stream.lineNo {
			return no
		} else {
			return 0
		}
	}
}

