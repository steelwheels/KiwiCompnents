/**
 * @file	KMLibraryCompiler.swift
 * @brief	Define KMLibraryCompiler class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import Amber
import KiwiEngine
import KiwiLibrary
import JavaScriptCore
import CoconutData

public class KMLibraryCompiler
{
	public func compile(context ctxt: KEContext, multiComponentViewController vcont: KMMultiComponentViewController, resource res: KEResource, processManager procmgr: CNProcessManager, console cons: CNFileConsole, environment env: CNEnvironment, config conf: KEConfig) -> Bool {
		defineComponentFuntion(context: ctxt, multiComponentViewController: vcont, resource: res)
		defineThreadFunction(multiViewController: vcont, context: ctxt, resource: res, processManager: procmgr, environment: env, console: cons, config: conf)
		return true
	}

	private func defineComponentFuntion(context ctxt: KEContext, multiComponentViewController vcont: KMMultiComponentViewController, resource res: KEResource) {
		/* enterView function */
		let enterfunc: @convention(block) (_ pathval: JSValue) -> JSValue = {
			(_ paramval: JSValue) -> JSValue in
			let result: JSValue
			if let src = self.enterParameter(parameter: paramval, resource: res) {
				let retval = self.enterView(multiViewController: vcont, source: src, context: ctxt)
				result = retval.toJSValue(context: ctxt)
			} else {
				result = JSValue(nullIn: ctxt)
			}
			return result
		}
		ctxt.set(name: "enterView", function: enterfunc)

		/* leaveView function */
		let leavefunc: @convention(block) (_ retval: JSValue) -> JSValue = {
			(_ retval: JSValue) -> JSValue in
			let nval = retval.toNativeValue()
			let res  = self.leaveView(multiViewController: vcont, returnValue: nval)
			return JSValue(bool: res, in: ctxt)
		}
		ctxt.set(name: "leaveView", function: leavefunc)
	}

	private func enterParameter(parameter param: JSValue, resource res: KEResource) -> KMSource? {
		if let paramstr = param.toString() {
			let subres = res.subset()
			return .subView(subres, paramstr)
		} else {
			return nil
		}
	}

	private func enterView(multiViewController vcont: KMMultiComponentViewController, source src: KMSource, context ctxt: KEContext) -> CNNativeValue {
		CNExecuteInMainThread(doSync: true, execute: {
			() -> Void in
			vcont.pushViewController(source: src, context: ctxt)
		})
		if !Thread.isMainThread {
			ctxt.suspend()
		}
		return vcont.returnValue
	}

	private func leaveView(multiViewController vcont: KMMultiComponentViewController, returnValue retval: CNNativeValue) -> Bool {
		var result: Bool = false
		CNExecuteInMainThread(doSync: true, execute: {
			() -> Void in
			vcont.setReturnValue(value: retval)
			if let ctxt = vcont.popViewController() {
				ctxt.resume()
				result = true
			} else {
				result = false
			}
		})
		return result
	}

	private func defineThreadFunction(multiViewController vcont: KMMultiComponentViewController, context ctxt: KEContext, resource res: KEResource, processManager procmgr: CNProcessManager, environment env: CNEnvironment, console cons: CNConsole, config conf: KEConfig) {
		/* Override Thread which is defined in KiwiLibrary */
		let thfunc: @convention(block) (_ nameval: JSValue, _ inval: JSValue, _ outval: JSValue, _ errval: JSValue) -> JSValue = {
			(_ nameval: JSValue, _ inval: JSValue, _ outval: JSValue, _ errval: JSValue) -> JSValue in
			let launcher = KMThreadLauncher(rootViewController: vcont, context: ctxt, resource: res, processManager: procmgr, environment: env, config: conf)
			return launcher.run(name: nameval, input: inval, output: outval, error: errval)
		}
		ctxt.set(name: "Thread", function: thfunc)

		/* Override run which is defined in KiwiLibrary */
		let runfunc: @convention(block) (_ pathval: JSValue, _ inval: JSValue, _ outval: JSValue, _ errval: JSValue) -> JSValue = {
			(_ pathval: JSValue, _ inval: JSValue, _ outval: JSValue, _ errval: JSValue) -> JSValue in
			let launcher = KMThreadLauncher(rootViewController: vcont, context: ctxt, resource: res, processManager: procmgr, environment: env, config: conf)
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
