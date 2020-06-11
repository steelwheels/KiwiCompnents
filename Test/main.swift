//
//  main.swift
//  UnitTest
//
//  Created by Tomoo Hamada on 2020/05/31.
//  Copyright © 2020 Steel Wheels Project. All rights reserved.
//

import KiwiComponents
import CoconutData
import Foundation

public func main()
{
	let console = CNFileConsole()
	console.print(string: "*** Unit test of KiwiObject\n")

	let res0 = parserTest(console: console)

	if res0 {
		console.print(string: "Summary: OK\n")
	} else {
		console.print(string: "Summary: NG\n")
	}
}

main()


