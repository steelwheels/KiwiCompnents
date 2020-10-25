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
	public enum AmberParameter {
		case url(URL)
		case name(String)	// thread name
	}

	public func compile(context ctxt: KEContext, multiComponentViewController vcont: KMMultiComponentViewController, environment env: CNEnvironment) -> NSError? {
		/* enterView function */
		let enterfunc: @convention(block) (_ pathval: JSValue) -> JSValue = {
			(_ paramval: JSValue) -> JSValue in
			let result: JSValue
			if let param = self.enterParameter(parameter: paramval, environment: env) {
				let retval = self.enterView(multiViewController: vcont, parameter: param)
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

		return nil
	}

	private func enterParameter(parameter param: JSValue, environment env: CNEnvironment) -> AmberParameter? {
		var result: AmberParameter? = nil
		if param.isURL {
			result = .url(param.toURL())
		} else if param.isString {
			if let paramstr = param.toString() {
				switch pathExtension(string: paramstr) {
				case "":
					result = .name(paramstr)
				case "amb":
					let url: URL
					if FileManager.default.isAbsolutePath(pathString: paramstr) {
						url = URL(fileURLWithPath: paramstr)
					} else {
						let curdir = env.currentDirectory
						url = URL(fileURLWithPath: paramstr, relativeTo: curdir)
					}
					result = .url(url)
				default:
					CNLog(logLevel: .error, message: "Invalid file extension for amber: \(paramstr)")
				}
			}
		}
		return result
	}

	private func enterView(multiViewController vcont: KMMultiComponentViewController, parameter param: AmberParameter) -> CNNativeValue {
		let retval: CNNativeValue
		switch param {
		case .name(let name):
			retval = vcont.launchViewController(viewName: name)
		case .url(let url):
			retval = vcont.launchViewController(sourceURL: url)
		}
		return retval
	}

	private func leaveView(multiViewController vcont: KMMultiComponentViewController, returnValue retval: CNNativeValue) -> Bool {
		vcont.setReturnValue(value: retval)
		return vcont.popViewController()
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
