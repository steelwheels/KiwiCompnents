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

public class KMLibraryCompiler
{
	public func compile(context ctxt: KEContext, viewController vcont: KMComponentViewController, resource res: KEResource, processManager procmgr: CNProcessManager, console cons: CNFileConsole, environment env: CNEnvironment, config conf: KEConfig) -> Bool {
		defineComponentFuntion(context: ctxt, viewController: vcont, resource: res)
		defineThreadFunction(context: ctxt, viewController: vcont, resource: res, processManager: procmgr, environment: env, console: cons, config: conf)
		return true
	}

	private func defineComponentFuntion(context ctxt: KEContext, viewController vcont: KMComponentViewController, resource res: KEResource) {
		/* enterView function */
		let enterfunc: @convention(block) (_ pathval: JSValue) -> JSValue = {
			(_ paramval: JSValue) -> JSValue in
			if let src = self.enterParameter(parameter: paramval, resource: res) {
				if let vstate = self.enterView(viewController: vcont, source: src) {
					let vobj = KMViewStateValue(context: ctxt, viewState: vstate)
					return JSValue(object: vobj, in: ctxt)
				} else {
					NSLog("No view state")
				}
			}
			return JSValue(nullIn: ctxt)
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

	private func enterView(viewController vcont: KMComponentViewController, source src: KMSource) -> KMViewState? {
		var vstate: KMViewState? = nil
		CNExecuteInMainThread(doSync: true, execute: {
			() -> Void in
			if let parent = vcont.parent as? KMMultiComponentViewController {
				vstate = parent.pushViewController(source: src)
			} else {
				NSLog("[Error] No parent controller")
			}
		})
		return vstate
	}

	private func leaveView(viewController vcont: KMComponentViewController, returnValue retval: CNNativeValue) {
		CNExecuteInMainThread(doSync: true, execute: {
			() -> Void in
			if let parent = vcont.parent as? KMMultiComponentViewController {
				if !parent.popViewController(returnValue: retval) {
					NSLog("Failed to pop view")
				}
			} else {
				NSLog("[Error] No parent controller")
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
