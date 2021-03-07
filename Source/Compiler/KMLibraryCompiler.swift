/**
 * @file	KMLibraryCompiler.swift
 * @brief	Define KMLibraryCompiler class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import KiwiEngine
import KiwiLibrary
import CoconutData
import JavaScriptCore

public class KMLibraryCompiler: AMBLibraryCompiler
{
	public func compile(context ctxt: KEContext, viewController vcont: KMComponentViewController, resource res: KEResource, processManager procmgr: CNProcessManager, console cons: CNFileConsole, environment env: CNEnvironment, config conf: KEConfig) -> Bool {
		/* Compile for the amber layer */
		super.compile(context: ctxt, resource: res, console: cons)
		/* Compile for this layer */
		defineComponentFuntion(context: ctxt, viewController: vcont, resource: res)
		defineThreadFunction(context: ctxt, viewController: vcont, resource: res, processManager: procmgr, environment: env, console: cons, config: conf)
		return true
	}

	private func defineComponentFuntion(context ctxt: KEContext, viewController vcont: KMComponentViewController, resource res: KEResource) {
		/* enterView function */
		let enterfunc: @convention(block) (_ pathval: JSValue, _ cbfunc: JSValue) -> JSValue = {
			(_ paramval: JSValue, _ cbfunc: JSValue) -> JSValue in
			if let src = self.enterParameter(parameter: paramval, resource: res) {
				self.enterView(viewController: vcont, context: ctxt, source: src, callback: cbfunc)
			}
			return JSValue(undefinedIn: ctxt)
		}
		ctxt.set(name: "enterView", function: enterfunc)

		/* leaveView function */
		let leavefunc: @convention(block) (_ retval: JSValue) -> JSValue = {
			(_ retval: JSValue) -> JSValue in
			let nval = retval.toNativeValue()
			self.leaveView(viewController: vcont, returnValue: nval)
			return JSValue(bool: true, in: ctxt)
		}
		ctxt.set(name: "leaveView", function: leavefunc)
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
			CNExecuteInMainThread(doSync: false, execute: {
				parent.pushViewController(source: src, callback: vcallback)
			})
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

	private func defineThreadFunction(context ctxt: KEContext, viewController vcont: KMComponentViewController, resource res: KEResource, processManager procmgr: CNProcessManager, environment env: CNEnvironment, console cons: CNConsole, config conf: KEConfig) {
		/* Override Thread which is defined in KiwiLibrary */
		let thfunc: @convention(block) (_ nameval: JSValue, _ inval: JSValue, _ outval: JSValue, _ errval: JSValue) -> JSValue = {
			(_ nameval: JSValue, _ inval: JSValue, _ outval: JSValue, _ errval: JSValue) -> JSValue in
			let launcher = KMThreadLauncher(viewController: vcont, context: ctxt, resource: res, processManager: procmgr, environment: env, config: conf)
			return launcher.run(name: nameval, input: inval, output: outval, error: errval)
		}
		ctxt.set(name: "Thread", function: thfunc)

		/* Override run which is defined in KiwiLibrary */
		let runfunc: @convention(block) (_ pathval: JSValue, _ inval: JSValue, _ outval: JSValue, _ errval: JSValue) -> JSValue = {
			(_ pathval: JSValue, _ inval: JSValue, _ outval: JSValue, _ errval: JSValue) -> JSValue in
			let launcher = KMThreadLauncher(viewController: vcont, context: ctxt, resource: res, processManager: procmgr, environment: env, config: conf)
			return launcher.run(path: pathval, input: inval, output: outval, error: errval)
		}
		ctxt.set(name: "run", function: runfunc)
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
