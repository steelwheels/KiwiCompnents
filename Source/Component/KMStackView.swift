/**
 * @file	KMStackView.swift
 * @brief	Define KMStackView class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiControls
import Amber
import KiwiEngine
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMStackView: KCStackView, AMBComponent
{
	private static let AxisItem		= "axis"
	private static let AlignmentItem	= "alignment"
	private static let DistributionItem	= "distribution"

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

		/* Sync initial value: axis */
		if let val = robj.int32Value(forProperty: KMStackView.AxisItem) {
			if let axisval = CNAxis(rawValue: Int(val)) {
				self.axis = axisval
			} else {
				cons.error(string: "Invalid raw value for axis: \(val)\n")
			}
		} else {
			robj.setInt32Value(value: Int32(self.axis.rawValue), forProperty: KMStackView.AxisItem)
		}
		/* Add listner: axis */
		robj.addObserver(forProperty: KMStackView.AxisItem, callback:  {
			(_ val: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMStackView.AxisItem) {
				if let axisval = CNAxis(rawValue: Int(val)) {
					CNExecuteInMainThread(doSync: false, execute: {
						self.axis = axisval
					})
				} else {
					let ival = robj.immediateValue(forProperty: KMStackView.AxisItem)
					CNLog(logLevel: .error, message: "Invalid property: name=\(KMStackView.AxisItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
				}
			}
		})

		/* Sync initial value: alignment */
		if let val = robj.int32Value(forProperty: KMStackView.AlignmentItem) {
			if let alignval = CNAlignment(rawValue: Int(val)) {
				CNExecuteInMainThread(doSync: false, execute: {
					self.alignment = alignval
				})
			} else {
				let ival = robj.immediateValue(forProperty: KMStackView.AlignmentItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMStackView.AlignmentItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		} else {
			robj.setInt32Value(value: Int32(self.alignment.rawValue), forProperty: KMStackView.AlignmentItem)
		}
		/* Add listner: alignment */
		robj.addObserver(forProperty: KMStackView.AlignmentItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMStackView.AxisItem) {
				if let alignval = CNAlignment(rawValue: Int(val)) {
					CNExecuteInMainThread(doSync: false, execute: {
						self.alignment = alignval
					})
				} else {
					let ival = robj.immediateValue(forProperty: KMStackView.AlignmentItem)
					CNLog(logLevel: .error, message: "Invalid property: name=\(KMStackView.AlignmentItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
				}
			}
		})

		/* Sync initial value: distribution */
		if let val = robj.int32Value(forProperty: KMStackView.DistributionItem) {
			if let distval = CNDistribution(rawValue: Int(val)) {
				self.distribution = distval
			} else {
				let ival = robj.immediateValue(forProperty: KMStackView.DistributionItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMStackView.DistributionItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		} else {
			robj.setInt32Value(value: Int32(self.distribution.rawValue), forProperty: KMStackView.DistributionItem)
		}
		/* Add listner: distribution */
		robj.addObserver(forProperty: KMStackView.DistributionItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMStackView.DistributionItem) {
				if let distval = CNDistribution(rawValue: Int(val)) {
					CNExecuteInMainThread(doSync: false, execute: {
						self.distribution = distval
					})
				} else {
					cons.error(string: "Invalid raw value for distribution: \(val)\n")
				}
			} else {
				let ival = robj.immediateValue(forProperty: KMStackView.DistributionItem)
				CNLog(logLevel: .error, message: "Invalid property: name=\(KMStackView.DistributionItem), value=\(String(describing: ival))", atFunction: #function, inFile: #file)
			}
		})

		return nil
	}

	public var children: Array<AMBComponent> {
		get {
			var result: Array<AMBComponent> = []
			for subview in self.arrangedSubviews() {
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
				super.addArrangedSubView(subView: view)
			})
		} else if let obj = comp as? AMBComponentObject {
			mChildObjects.append(obj)
		} else {
			CNLog(logLevel: .error, message: "Failed to add child component", atFunction: #function, inFile: #file)
		}
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(stackView: self)
	}
}

