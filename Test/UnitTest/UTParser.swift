/**
 * @file	UTParser.swift
 * @brief	Unit test for KMObjectParser class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiComponents
import CoconutData
import Foundation

public func parserTest(console cons: CNConsole) -> Bool {
	var result = true
	let stmt0  = "{ a: 10 }"
	let stmt1  = "{ a: 10 } // comment"
	let stmt2  =   "{\n"
		     + "  a: 10, \n"
		     + "  b: {\n"
		     + "    c: 12.3\n"
		     + "  }\n"
		     + "}"
	let stmt3  = "{ a: [10, 20] } // comment"
	let stmt4  = "{ a: [ {a: 10}, {a: 20}] } // comment"
	let stmt5  = "{\n"
		     + "text: %{ this \n"
		     + "          is text\n"
		     + "  value %}\n"
		     + "}\n"
	for stmt in [stmt0, stmt1, stmt2, stmt3, stmt4, stmt5] {
		let res0 = parse(string: stmt, console: cons)
		result = result && res0
	}
	return result
}

private func parse(string str: String, console cons: CNConsole) -> Bool
{
	cons.print(string: "+ parse test\n")
	let result: Bool
	let parser = CNNativeValueParser()
	switch parser.parse(source: str) {
	case .ok(let obj):
		let text = obj.toText()
		text.print(console: cons, terminal: "")
		result = true
	case .error(let err):
		cons.print(string: "[Error] \(err.description)\n")
		result = false
	}
	return result
}
