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
		compileLibraryFiles(context: ctxt, viewController: vcont, console: cons)
		return true
	}

	private func defineComponentFuntion(context ctxt: KEContext, viewController vcont: KMComponentViewController, resource res: KEResource) {
		/* enterView function */
		let enterfunc: @convention(block) (_ pathval: JSValue) -> JSValue = {
			(_ paramval: JSValue) -> JSValue in
			let result: JSValue
			if let src = self.enterParameter(parameter: paramval, resource: res) {
				self.enterView(viewController: vcont, source: src)
				result = JSValue(bool: true, in: ctxt)
			} else {
				result = JSValue(bool: false, in: ctxt)
			}
			return result
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
			let subres = res.subset()
			return .subView(subres, paramstr)
		} else {
			return nil
		}
	}

	private func enterView(viewController vcont: KMComponentViewController, source src: KMSource)  {
		CNExecuteInMainThread(doSync: true, execute: {
			() -> Void in
			if let parent = vcont.parent as? KMMultiComponentViewController {
				parent.pushViewController(source: src)
			} else {
				NSLog("[Error] No parent controller")
			}
		})
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

	private func compileLibraryFiles(context ctxt: KEContext, viewController vcont: KMComponentViewController, console cons: CNFileConsole) {
		/* Define global */
		ctxt.set(name: "viewState", object: vcont.state)
		
		/* Load files*/
		switch CNFilePath.URLsForResourceFiles(fileExtension: "js", subdirectory: nil, forClass: KMLibraryCompiler.self) {
		case .ok(let urls):
			for url in urls {
				if let script = url.loadContents() {
					/* Compile the script */
					ctxt.evaluateScript(script as String)
				} else {
					cons.error(string: "Failed to compile: \(url.absoluteString)")
				}
			}
		case .error(let err):
			cons.error(string: "[Error] \(err.toString())\n")
		@unknown default:
			cons.error(string: "[Error] Unexpected case\n")
		}
	}
}
