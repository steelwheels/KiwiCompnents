//
//  ViewController.swift
//  UnitTest
//
//  Created by Tomoo Hamada on 2020/09/24.
//

import KiwiControls
import KiwiEngine
import KiwiLibrary
import CoconutData
import Cocoa
import JavaScriptCore

class ViewController: NSViewController
{
	private var mConsole:	CNFileConsole?	= nil

	@IBOutlet weak var mTerminalView: KCTerminalView!

	override func viewDidLoad() {
		super.viewDidLoad()

		mTerminalView.foregroundTextColor = CNColor.black
		mTerminalView.backgroundTextColor = CNColor.white

		// Do any additional setup after loading the view.
		let inhdl  = mTerminalView.inputFileHandle
		let outhdl = mTerminalView.outputFileHandle
		let errhdl = mTerminalView.errorFileHandle
		let cons   = CNFileConsole(input: inhdl, output: outhdl, error: errhdl)
		mConsole   = cons

		guard let vm = JSVirtualMachine() else {
			cons.print(string: "Failed to allocate VM\n")
			return
		}

		let context = KEContext(virtualMachine: vm)
		let compiler = KLCompiler()

		//open override func compileBase(context ctxt: KEContext, terminalInfo terminfo: CNTerminalInfo, environment env: CNEnvironment, console cons: CNFileConsole, config conf: KEConfig) -> Bool {

		let terminfo = CNTerminalInfo(width: 80, height: 25)
		let env      = CNEnvironment()
		let config   = KEConfig(applicationType: .window, doStrict: true, logLevel: .detail)
		guard compiler.compileBase(context: context, terminalInfo: terminfo, environment: env, console: cons, config: config) else {
			cons.print(string: "Failed to compile\n")
			return
		}

		cons.print(string: "Hello, world !!\n")
		let result0 = UTObjectValueTable(context: context, console: cons)
		if result0 {
			cons.print(string: "Summary: OK\n")
		} else {
			cons.print(string: "Summary: NG\n")
		}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}

