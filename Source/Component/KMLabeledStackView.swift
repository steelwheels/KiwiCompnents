/**
 * @file	KMLabeledStackView.swift
 * @brief	Define KMLabeledStackView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Foundation
import KiwiControls
import Amber
import KiwiEngine
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMLabeledStackView: KCLabeledStackView, AMBComponent
{
	private static let AxisItem		= "axis"
	private static let AlignmentItem	= "alignment"
	private static let DistributionItem	= "distribution"
	private static let TitleItem		= "title"

	private var mReactObject:	AMBReactObject?
	private var mChildObjects:	Array<AMBComponentObject>

	public var reactObject: AMBReactObject {
		get {
			if let robj = mReactObject {
				return robj
			} else {
				fatalError("No react object")
			}
		}
	}

	public init(){
		mReactObject	= nil
		mChildObjects	= []
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 188, height: 21)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 32)
		#endif
		super.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		mReactObject	= nil
		mChildObjects	= []
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, console cons: CNConsole) -> NSError? {
		mReactObject	= robj

		/* Sync initial value: title */
		if let val = robj.stringValue(forProperty: KMLabeledStackView.TitleItem) {
			self.title = val
		} else {
			robj.setStringValue(value: self.title, forProperty: KMLabeledStackView.TitleItem)
		}
		/* Add listner: title */
		robj.addObserver(forProperty: KMLabeledStackView.TitleItem, callback:  {
			(_ val: Any) -> Void in
			if let val = robj.stringValue(forProperty: KMLabeledStackView.TitleItem) {
				self.title = val
			} else {
				let ival = robj.immediateValue(forProperty: KMLabeledStackView.TitleItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMLabeledStackView.TitleItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		/* Sync initial value: axis */
		if let val = robj.int32Value(forProperty: KMLabeledStackView.AxisItem) {
			if let axisval = CNAxis(rawValue: Int32(val)) {
				self.contentsView.axis = axisval
			} else {
				let ival = robj.immediateValue(forProperty: KMLabeledStackView.AxisItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMLabeledStackView.AxisItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		} else {
			robj.setInt32Value(value: self.contentsView.axis.rawValue, forProperty: KMLabeledStackView.AxisItem)
		}
		/* Add listner: axis */
		robj.addObserver(forProperty: KMLabeledStackView.AxisItem, callback:  {
			(_ val: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMLabeledStackView.AxisItem) {
				if let axisval = CNAxis(rawValue: val) {
					CNExecuteInMainThread(doSync: false, execute: {
						self.contentsView.axis = axisval
					})
				} else {
					let ival = robj.immediateValue(forProperty: KMLabeledStackView.AxisItem)
					CNLog(logLevel: .error, message: "Invalid property: name=\(KMLabeledStackView.AxisItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
				}
			}
		})

		/* Sync initial value: alignment */
		if let val = robj.int32Value(forProperty: KMLabeledStackView.AlignmentItem) {
			if let alignval = CNAlignment(rawValue: val) {
				self.contentsView.alignment = alignval
			} else {
				let ival = robj.immediateValue(forProperty: KMLabeledStackView.AlignmentItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMLabeledStackView.AlignmentItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		} else {
			robj.setInt32Value(value: self.contentsView.alignment.rawValue, forProperty: KMLabeledStackView.AlignmentItem)
		}
		/* Add listner: alignment */
		robj.addObserver(forProperty: KMLabeledStackView.AlignmentItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMLabeledStackView.AxisItem) {
				if let alignval = CNAlignment(rawValue: val) {
					CNExecuteInMainThread(doSync: false, execute: {
						self.contentsView.alignment = alignval
					})
				} else {
					let ival = robj.immediateValue(forProperty: KMLabeledStackView.AlignmentItem)
					CNLog(logLevel: .error, message: "Invalid property: name=\(KMLabeledStackView.AlignmentItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
				}
			}
		})

		/* Sync initial value: distribution */
		if let val = robj.int32Value(forProperty: KMLabeledStackView.DistributionItem) {
			if let distval = CNDistribution(rawValue: val) {
				self.contentsView.distribution = distval
			} else {
				let ival = robj.immediateValue(forProperty: KMLabeledStackView.DistributionItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMLabeledStackView.DistributionItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		} else {
			robj.setInt32Value(value: self.contentsView.distribution.rawValue, forProperty: KMLabeledStackView.DistributionItem)
		}
		/* Add listner: distribution */
		robj.addObserver(forProperty: KMLabeledStackView.DistributionItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMLabeledStackView.DistributionItem) {
				if let distval = CNDistribution(rawValue: val) {
					CNExecuteInMainThread(doSync: false, execute: {
						self.contentsView.distribution = distval
					})
				} else {
					let ival = robj.immediateValue(forProperty: KMLabeledStackView.DistributionItem)
					CNLog(logLevel: .error, message: "Invalid property: name=\(KMLabeledStackView.DistributionItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
				}
			}
		})

		return nil
	}

	public var children: Array<AMBComponent> {
		get {
			var result: Array<AMBComponent> = []
			for subview in self.contentsView.arrangedSubviews() {
				if let comp = subview as? AMBComponent {
					result.append(comp)
				}
			}
			result.append(contentsOf: mChildObjects)
			return result
		}
	}

	public func addChild(component comp: AMBComponent) {
		if let view = comp as? KCView {
			CNExecuteInMainThread(doSync: false, execute: {
				() -> Void in
				super.contentsView.addArrangedSubView(subView: view)
			})
		} else if let obj = comp as? AMBComponentObject {
			mChildObjects.append(obj)
		} else {
			CNLog(logLevel: .error, message: "Failed to add child component", atFunction: #function, inFile: #file)
		}
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(labeledStackView: self)
	}
}
