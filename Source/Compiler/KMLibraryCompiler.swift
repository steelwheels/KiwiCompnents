/**
 * @file	KMLibraryCompiler.swift
 * @brief	Define KMLibraryCompiler class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import KiwiControls
import KiwiEngine
import KiwiLibrary
import CoconutData
import JavaScriptCore

public class KMLibraryCompiler
{
	private var mViewController: 	KMComponentViewController

	public init(viewController vcont: KMComponentViewController) {
		mViewController = vcont
	}

	public func compile(context ctxt: KEContext, resource res: KEResource, processManager procmgr: CNProcessManager, terminalInfo terminfo: CNTerminalInfo, environment env: CNEnvironment, console cons: CNConsole, config conf: KEConfig) -> Bool {
		defineComponentFuntion(context: ctxt, viewController: mViewController, resource: res)
		defineThreadFunction(context: ctxt, viewController: mViewController, resource: res, processManager: procmgr, environment: env, console: cons, config: conf)
		importBuiltinLibrary(context: ctxt, console: cons, config: conf)
		return true
	}

	private func defineComponentFuntion(context ctxt: KEContext, viewController vcont: KMComponentViewController, resource res: KEResource) {
		/* enterView function */
		let enterfunc: @convention(block) (_ pathval: JSValue, _ cbfunc: JSValue) -> Void = {
			(_ paramval: JSValue, _ cbfunc: JSValue) -> Void in
			CNExecuteInMainThread(doSync: false, execute: {
				() -> Void in
				if let src = self.enterParameter(parameter: paramval, resource: res) {
					self.enterView(viewController: vcont, context: ctxt, source: src, callback: cbfunc)
				}
			})
		}
		ctxt.set(name: "_enterView", function: enterfunc)

		/* leaveView function */
		let leavefunc: @convention(block) (_ retval: JSValue) -> JSValue = {
			(_ retval: JSValue) -> JSValue in
			let nval = retval.toNativeValue()
			self.leaveView(viewController: vcont, returnValue: nval)
			return JSValue(bool: true, in: ctxt)
		}
		ctxt.set(name: "leaveView", function: leavefunc)

		/* _alert */
		let alertfunc: @convention(block) (_ msg: JSValue, _ cbfunc: JSValue) -> Void = {
			(_ msg: JSValue, _ cbfunc: JSValue) -> Void in
			self.defineAlertFunction(message: msg, callback: cbfunc, viewController: vcont, context: ctxt)
		}
		ctxt.set(name: "_alert", function: alertfunc)
	}

	private func enterParameter(parameter param: JSValue, resource res: KEResource) -> KMSource? {
		if let paramstr = param.toString() {
			return .subView(res, paramstr)
		} else {
			return nil
		}
	}

	private func enterView(viewController vcont: KMComponentViewController, context ctxt: KEContext, source src: KMSource, callback cbfunc: JSValue) {
		if let parent = vcont.parent as? KMMultiComponentViewController {
			let vcallback: KMMultiComponentViewController.ViewSwitchCallback = {
				(_ val: CNNativeValue) -> Void in
				CNExecuteInUserThread(level: .event, execute: {
					cbfunc.call(withArguments: [val.toJSValue(context: ctxt)])
				})
			}
			parent.pushViewController(source: src, callback: vcallback)
		} else {
			CNLog(logLevel: .error, message: "[Error] No parent controller")
		}
	}

	private func leaveView(viewController vcont: KMComponentViewController, returnValue retval: CNNativeValue) {
		CNExecuteInMainThread(doSync: false, execute: {
			() -> Void in
			if let parent = vcont.parent as? KMMultiComponentViewController {
				if !parent.popViewController(returnValue: retval) {
					CNLog(logLevel: .error, message: "Failed to pop view")
				}
			} else {
				CNLog(logLevel: .error, message: "No parent controller")
			}
		})
	}

	private func defineAlertFunction(message msg: JSValue, callback cbfunc: JSValue, viewController vcont: KMComponentViewController, context ctxt: KEContext) -> Void {
		CNExecuteInMainThread(doSync: false, execute: {
			if let msgstr = msg.toString() {
				KCAlert.alert(type: .information, messgage: msgstr, in: vcont, callback: {
					(_ retval: Int) -> Void in
					if let retobj = JSValue(int32: Int32(retval), in: ctxt) {
						cbfunc.call(withArguments: [retobj])
					} else {
						NSLog("Failed to allocate return value")
						cbfunc.call(withArguments: [])
					}
				})
			} else {
				if let retobj = JSValue(int32: -1, in: ctxt) {
					cbfunc.call(withArguments: [retobj])
				} else {
					cbfunc.call(withArguments: [])
				}
			}
		})
	}

	private func defineThreadFunction(context ctxt: KEContext, viewController vcont: KMComponentViewController, resource res: KEResource, processManager procmgr: CNProcessManager, environment env: CNEnvironment, console cons: CNConsole, config conf: KEConfig) {
		/* Override Thread which is defined in KiwiLibrary */
		let thfunc: @convention(block) (_ pathval: JSValue, _ inval: JSValue, _ outval: JSValue, _ errval: JSValue) -> JSValue = {
			(_ pathval: JSValue, _ inval: JSValue, _ outval: JSValue, _ errval: JSValue) -> JSValue in
			let launcher = KMThreadLauncher(viewController: vcont, context: ctxt, resource: res, processManager: procmgr, environment: env, config: conf)
			return launcher.run(path: pathval, input: inval, output: outval, error: errval)
		}
		ctxt.set(name: "Thread", function: thfunc)

		/* Override run which is defined in KiwiLibrary */
		let runfunc: @convention(block) (_ pathval: JSValue, _ inval: JSValue, _ outval: JSValue, _ errval: JSValue) -> JSValue = {
			(_ pathval: JSValue, _ inval: JSValue, _ outval: JSValue, _ errval: JSValue) -> JSValue in
			let launcher = KMThreadLauncher(viewController: vcont, context: ctxt, resource: res, processManager: procmgr, environment: env, config: conf)
			return launcher.run(path: pathval, input: inval, output: outval, error: errval)
		}
		ctxt.set(name: "_run", function: runfunc)
	}

	private func importBuiltinLibrary(context ctxt: KEContext, console cons: CNConsole, config conf: KEConfig)
	{
		let libnames = ["window"]
		do {
			for libname in libnames {
				if let url = CNFilePath.URLForResourceFile(fileName: libname, fileExtension: "js", subdirectory: "Library", forClass: KMLibraryCompiler.self) {
					let script = try String(contentsOf: url, encoding: .utf8)
					let _ = compile(context: ctxt, statement: script, console: cons, config: conf)
				} else {
					cons.error(string: "Built-in script \"\(libname)\" is not found.\n")
				}
			}
		} catch {
			cons.error(string: "Failed to read built-in script in KiwiComponents")
		}
	}

	public func compile(context ctxt: KEContext, statement stmt: String, console cons: CNConsole, config conf: KEConfig) -> JSValue? {
		switch conf.logLevel {
		case .nolog, .error, .warning, .debug:
			break
		case .detail:
			cons.print(string: stmt)
		@unknown default:
			break
		}
		return ctxt.evaluateScript(stmt)
	}
	
	private func pathExtension(string str: String) -> String {
		let nsstr = str as NSString
		return nsstr.pathExtension
	}

	private class func stringToURL(string str: String, environment env: CNEnvironment) -> URL {
		let result: URL
		if FileManager.default.isAbsolutePath(pathString: str) {
			result = URL(fileURLWithPath: str)
		} else {
			let curdir = env.currentDirectory
			result = URL(fileURLWithPath: str, relativeTo: curdir)
		}
		return result
	}

	private class func vallueToFileStream(value val: JSValue) -> CNFileStream? {
		if let obj = val.toObject() {
			if let file = obj as? KLFile {
				return .fileHandle(file.fileHandle)
			} else if let pipe = obj as? KLPipe {
				return .pipe(pipe.pipe)
			}
		}
		return nil
	}
}


