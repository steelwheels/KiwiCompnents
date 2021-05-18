/**
 * @file	KMTableData.swift
 * @brief	Define KMTableData class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import KiwiControls
import Amber
import CoconutData
import Foundation

public class KMTableData: CNNativeValueTable, KCTableDelegate
{
	private var mConsole: CNConsole

	public init(console cons: CNConsole){
		mConsole = cons
	}

	public func set(colmunName cname: String, rowIndex ridx: Int, data dat: Any?) {
		if let val = dat as? CNNativeValue {
			self.setValue(title: cname, row: ridx, value: val)
		} else {
			NSLog("Failed to set table value at \(#function) in \(#file)")
		}
	}

	public func view(colmunName cname: String, rowIndex ridx: Int) -> KCView? {
		let val = self.value(title: cname, row: ridx)
		return valueToView(value: val)
	}

	public func view(colmunIndex cidx: Int, rowIndex ridx: Int) -> KCView? {
		let val = self.value(column: cidx, row: ridx)
		return valueToView(value: val)
	}

	private func valueToView(value val: CNNativeValue) -> KCView {
		let result: KCView
		switch val {
		case .stringValue(let str):
			result = textToView(text: str)
		case .imageValue(let img):
			let view = KCImageView()
			view.set(image: img)
			result = view
		case .objectValue(let obj):
			if let ambobj = obj as? AMBReactObject {
				result = objectToView(object: ambobj)
			} else {
				result = textToView(text: obj.description)
			}
		default:
			let str = val.toText().toStrings(terminal: "").joined(separator: "\n")
			result = textToView(text: str)
		}
		#if os(OSX)
		let size = result.fittingSize
		result.setFrameSize(size)
		#endif
		return result
	}

	private func objectToView(object obj: AMBReactObject) -> KCView {
		let result: KCView
		let mapper = KMComponentMapper()
		switch mapper.map(object: obj, console: mConsole) {
		case .ok(let comp):
			if let view = comp as? KCView {
				result = view
			} else {
				result = textToView(text: "<NaV>")
			}
		case .error(let err):
			mConsole.error(string: "[Error] \(err.description)")
			result = textToView(text: "<Err>")
		@unknown default:
			mConsole.error(string: "[Error] Unknown case")
			result = textToView(text: "<Unk>")
		}
		#if os(OSX)
			let fsize = result.fittingSize
			result.setFrameSize(fsize)
		#endif
		return result
	}

	private func textToView(text txt: String) -> KCView {
		let textview  = KCTextEdit()
		textview.text = txt
		return textview
	}
}
