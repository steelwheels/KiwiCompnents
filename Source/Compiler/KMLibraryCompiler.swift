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
		defineComponentFuntion(context: ctxt, multiComponentViewController: vcont, resource: res, environment: env)
		defineThreadFunction(multiViewController: vcont, context: ctxt, resource: res, processManager: procmgr, environment: env, console: cons, config: conf)
		return true
	}

	private func defineComponentFuntion(context ctxt: KEContext, multiComponentViewController vcont: KMMultiComponentViewController, resource res: KEResource, environment env: CNEnvironment) {
		/* enterView function */
		let enterfunc: @convention(block) (_ pathval: JSValue) -> JSValue = {
			(_ paramval: JSValue) -> JSValue in
			let result: JSValue
			if let url = self.enterParameter(parameter: paramval, resource: res, environment: env) {
				let retval = self.enterView(multiViewController: vcont, sourceURL: url)
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

	private func enterParameter(parameter param: JSValue, resource res: KEResource, environment env: CNEnvironment) -> URL? {
		var result: URL? = nil
		if param.isURL {
			result = param.toURL()
		} else if param.isString {
			if let paramstr = param.toString() {
				switch pathExtension(string: paramstr) {
				case "":
					if let url = res.URLOfView(identifier: paramstr) {
						result = url
					} else {
						CNLog(logLevel: .error, message: "No view item: \(paramstr)")
					}
				case "amb":
					let url: URL
					if FileManager.default.isAbsolutePath(pathString: paramstr) {
						url = URL(fileURLWithPath: paramstr)
					} else {
						let curdir = env.currentDirectory
						url = URL(fileURLWithPath: paramstr, relativeTo: curdir)
					}
					result = url
				default:
					CNLog(logLevel: .error, message: "Invalid file extension for amber: \(paramstr)")
				}
			}
		}
		return result
	}

	private func enterView(multiViewController vcont: KMMultiComponentViewController, sourceURL surl: URL) -> CNNativeValue {
		var retval: CNNativeValue = .nullValue
		CNExecuteInMainThread(doSync: true, execute: {
			() -> Void in
			retval = vcont.launchViewController(sourceURL: surl)
		})
		return retval
	}

	private func leaveView(multiViewController vcont: KMMultiComponentViewController, returnValue retval: CNNativeValue) -> Bool {
		var result: Bool = false
		CNExecuteInMainThread(doSync: true, execute: {
			() -> Void in
			vcont.setReturnValue(value: retval)
			result = vcont.popViewController()
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
