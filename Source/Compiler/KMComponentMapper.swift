/**
 * @file	KMComponentMapper.swift
 * @brief	Define KMComponentMapper class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Amber
import KiwiEngine
import KiwiLibrary
import JavaScriptCore
import CoconutData

public class KMComponentMapper: AMBComponentMapper
{
	public typealias  MapResult = AMBComponentMapper.MapResult

	open override func map(object robj: AMBReactObject, console cons: CNConsole) -> MapResult {
		return mapView(object: robj, console: cons)
	}

	public func mapView(object robj: AMBReactObject, console cons: CNConsole) -> MapResult {
		let classname = robj.frame.className
		let newcomp    : AMBComponent
		let hassubview : Bool
		switch classname {
		case "Button":
			newcomp     = KMButton()
			hassubview  = false
		case "CheckBox":
			newcomp     = KMCheckBox()
			hassubview  = false
		case "HBox":
			let comp    = KMStackView()
			comp.axis   = .horizontal
			newcomp     = comp
			hassubview  = true
		case "Icon":
			newcomp     = KMIcon()
			hassubview  = false
		case "Image":
			newcomp     = KMImage()
			hassubview  = false
		case "Label":
			let comp    = KMTextEdit()
			comp.mode   = .label
			newcomp     = comp
			hassubview  = false
		case "LabelBox":
			newcomp     = KMLabeledStackView()
			hassubview  = true
		case "Table":
			newcomp     = KMTableView()
			hassubview  = false
		case "Terminal":
			newcomp     = KMTerminalView()
			hassubview  = false
		case "TextField":
			let comp    = KMTextEdit()
			comp.mode   = .view(40)
			newcomp     = comp
			hassubview  = false
		case "VBox":
			let comp    = KMStackView()
			comp.axis   = .vertical
			newcomp     = comp
			hassubview  = true
		default:
			/* Not view object */
			return mapData(object: robj, console: cons)
		}
		if let err = newcomp.setup(reactObject: robj, console: cons) {
			return .error(err)
		}
		if hassubview {
			if let err = mapChildView(component: newcomp, console: cons) {
				return .error(err)
			}
		} else {
			if let err = mapChildData(component: newcomp, console: cons) {
				return .error(err)
			}
		}
		return .ok(newcomp)
	}

	public func mapData(object robj: AMBReactObject, console cons: CNConsole) -> MapResult {
		let classname = robj.frame.className
		let newcomp    : AMBComponent
		switch classname {
		case "Shell":
			newcomp = KMShell()
		default:
			return super.mapObject(object: robj, console: cons)
		}
		if let err = newcomp.setup(reactObject: robj, console: cons) {
			return .error(err)
		}
		if let err = mapChildData(component: newcomp, console: cons) {
			return .error(err)
		} else {
			return .ok(newcomp)
		}
	}

	public func mapChildView(component comp: AMBComponent, console cons: CNConsole) -> NSError? {
		let robj = comp.reactObject
		for prop in robj.scriptedPropertyNames {
			if let child = robj.childFrame(forProperty: prop) {
				switch mapView(object: child, console: cons) {
				case .ok(let childcomp):
					comp.addChild(component: childcomp)
				case .error(let err):
					return err
				@unknown default:
					return NSError.parseError(message: "Can not happen")
				}
			}
		}
		return nil
	}

	public func mapChildData(component comp: AMBComponent, console cons: CNConsole) -> NSError? {
		let robj = comp.reactObject
		for prop in robj.scriptedPropertyNames {
			if let child = robj.childFrame(forProperty: prop) {
				switch mapData(object: child, console: cons) {
				case .ok(let childcomp):
					comp.addChild(component: childcomp)
				case .error(let err):
					return err
				@unknown default:
					return NSError.parseError(message: "Can not happen")
				}
			}
		}
		return nil
	}
}




