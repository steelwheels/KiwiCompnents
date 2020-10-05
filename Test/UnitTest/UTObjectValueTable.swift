/**
 * @file	UTObjectValueTable.swift
 * @brief	Define UTObjectValueTable class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiComponents
import KiwiEngine
import CoconutData
import JavaScriptCore
import Foundation

public func UTObjectValueTable(context ctxt: KEContext, console cons: CNFileConsole) -> Bool
{
	cons.print(string: "** UTObjectValueTable\n")

	let table = KMObservedValueTable(context: ctxt)

	guard let keya = JSValue(object: "a", in: ctxt) else {
		cons.print(string: "Failed to allocate key\n")
		return false
	}
	table.set(keya, JSValue(int32: 123, in: ctxt))
	let vala = table.get(keya)
	guard vala.isNumber else {
		cons.print(string: "Failed to get value\n")
		return false
	}
	cons.print(string: "a = \(vala.description)\n")
	guard vala.toInt32() == 123 else {
		cons.print(string: "Unexpected value\n")
		return false
	}

	let funcsrc = "function callback(a) { console.print(\"SCRIPT-CALLBACK: a = \" + a + \"\\n\") ; return a + 1 ; }\n"
	ctxt.evaluateScript(funcsrc)
	guard let funcval = ctxt.getValue(name: "callback") else {
		cons.print(string: "ScriptCallback function is NOT defined")
		return false
	}
	cons.print(string: "funcval = \(funcval.description)\n")

	/* Set callback */
	var result = true
	table.setScriptCallback(keya, funcval)
	table.setComponentCallback(forKey: "a", callback: {
		(_ value: CNNativeValue) -> Void in
		if let num = value.toNumber() {
			cons.print(string: "COMPONENT-CALLBACK: a = \(num.description)\n")
		} else {
			cons.print(string: "COMPONENT-CALLBACK: a = INVALID\n")
			result = false
		}
	})
	table.set(keya, JSValue(int32: 345, in: ctxt))

	return result
}
