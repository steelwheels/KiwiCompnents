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
	open override func map(object robj: AMBReactObject, console cons: CNConsole) -> Result<AMBComponent, NSError> {
		return mapView(object: robj, console: cons)
	}

	public func mapView(object robj: AMBReactObject, console cons: CNConsole) -> Result<AMBComponent, NSError> {
		let classname = robj.frame.className
		let newcomp    : AMBComponent
		let hassubview : Bool
		switch classname {
		case "Bitmap":
			newcomp	    = KMBitmap()
			hassubview  = false
		case "Button":
			newcomp     = KMButton()
			hassubview  = false
		case "Card":
			newcomp	    = KMCardView()
			hassubview  = true
		case "CheckBox":
			newcomp     = KMCheckBox()
			hassubview  = false
		case "CollectionView":
			newcomp	    = KMCollectionView()
			hassubview  = false
		case "DrawingView":
			newcomp	    = KMDrawingView()
			hassubview  = false
		case "Graphics2D":
			newcomp	    = KMGraphics2D()
			hassubview  = false
		case "HBox":
			let comp    = KMStackView()
			comp.axis   = .horizontal
			newcomp     = comp
			hassubview  = true
		case "Icon":
			newcomp     = KMIcon()
			hassubview  = false
		case "ImageView":
			newcomp     = KMImage()
			hassubview  = false
		case "Label":
			let comp    = KMTextEdit()
			comp.isBold 	= true
			comp.isEditable	= false
			newcomp		= comp
			hassubview	= false
		case "LabeledBox":
			newcomp     = KMLabeledStackView()
			hassubview  = true
		case "PopupMenu":
			newcomp     = KMPopupMenu()
			hassubview  = false
		case "RadioButtons":
			newcomp	    = KMRadioButtons()
			hassubview  = false
		case "Stepper":
			newcomp     = KMStepper()
			hassubview  = false
		case "TableView":
			newcomp     = KMTableView()
			hassubview  = false
		case "Terminal":
			newcomp     = KMTerminalView()
			hassubview  = false
		case "TextField":
			let comp    = KMTextEdit()
			comp.isBold	= false
			comp.isEditable	= true
			newcomp		= comp
			hassubview	= false
		case "VBox":
			let comp    = KMStackView()
			comp.axis   = .vertical
			newcomp     = comp
			hassubview  = true
		default:
			/* Not view object */
			return mapData(object: robj, console: cons)
		}
		if hassubview {
			if let err = mapChildView(component: newcomp, reactObject: robj, console: cons) {
				return .failure(err)
			}
		} else {
			if let err = mapChildData(component: newcomp, reactObject: robj, console: cons) {
				return .failure(err)
			}
		}
		if let err = newcomp.setup(reactObject: robj, console: cons) {
			return .failure(err)
		}
		return .success(newcomp)
	}

	public func mapData(object robj: AMBReactObject, console cons: CNConsole) -> Result<AMBComponent, NSError>  {
		let classname = robj.frame.className
		let newcomp    : AMBComponent
		switch classname {
		case "Shell":
			newcomp = KMShell()
		case "AddressBook":
			newcomp = KMContactDatabase()
		case "Dictionary":
			newcomp = KMDictionaryData()
		case "Table":
			newcomp = KMTableData()
		default:
			switch super.mapObject(object: robj, console: cons) {
			case .success(let comp):
				newcomp = comp
			case .failure(let err):
				return .failure(err)
			}
		}
		if let err = mapChildData(component: newcomp, reactObject: robj, console: cons) {
			return .failure(err)
		}
		if let err = newcomp.setup(reactObject: robj, console: cons) {
			return .failure(err)
		} else {
			return .success(newcomp)
		}
	}

	public func mapChildView(component comp: AMBComponent, reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		for prop in robj.scriptedPropertyNames {
			if let child = robj.childFrame(forProperty: prop) {
				switch mapView(object: child, console: cons) {
				case .success(let childcomp):
					comp.addChild(component: childcomp)
				case .failure(let err):
					return err
				}
			}
		}
		return nil
	}

	public func mapChildData(component comp: AMBComponent, reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		for prop in robj.scriptedPropertyNames {
			if let child = robj.childFrame(forProperty: prop) {
				switch mapData(object: child, console: cons) {
				case .success(let childcomp):
					comp.addChild(component: childcomp)
				case .failure(let err):
					return err
				}
			}
		}
		return nil
	}
}

