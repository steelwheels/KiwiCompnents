/**
 * @file	KMCardView.swift
 * @brief	Define KMCardView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import Amber
import KiwiControls
import KiwiEngine
import CoconutData
import Foundation
#if os(iOS)
import UIKit
#endif

public class KMCardView: KCCardView, AMBComponent
{
	static let AxisItem		= "axis"
	static let AlignmentItem	= "align"
	static let DistributionItem	= "distribution"
	static let IndexItem		= "index"

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
		if let val = robj.int32Value(forProperty: KMCardView.AxisItem) {
			if let axisval = CNAxis(rawValue: Int32(val)) {
				self.axis = axisval
			} else {
				cons.error(string: "Invalid raw value for axis: \(val)\n")
			}
		} else {
			robj.setInt32Value(value: self.axis.rawValue, forProperty: KMCardView.AxisItem)
		}
		/* Add listner: axis */
		robj.addObserver(forProperty: KMCardView.AxisItem, callback:  {
			(_ val: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMCardView.AxisItem) {
				if let axisval = CNAxis(rawValue: val) {
					CNExecuteInMainThread(doSync: false, execute: {
						self.axis = axisval
					})
				} else {
					cons.error(string: "Invalid raw value for axis: \(val)\n")
				}
			}
		})

		/* Sync initial value: alignment */
		if let val = robj.int32Value(forProperty: KMCardView.AlignmentItem) {
			if let alignval = CNAlignment(rawValue: val) {
				CNExecuteInMainThread(doSync: false, execute: {
					self.alignment = alignval
				})
			} else {
				cons.error(string: "Invalid raw value for alignment: \(val)\n")
			}
		} else {
			robj.setInt32Value(value: self.alignment.rawValue, forProperty: KMCardView.AlignmentItem)
		}
		/* Add listner: alignment */
		robj.addObserver(forProperty: KMCardView.AlignmentItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMCardView.AxisItem) {
				if let alignval = CNAlignment(rawValue: val) {
					CNExecuteInMainThread(doSync: false, execute: {
						self.alignment = alignval
					})
				} else {
					cons.error(string: "Invalid raw value for alignment: \(val)\n")
				}
			}
		})

		/* Sync initial value: distribution */
		if let val = robj.int32Value(forProperty: KMCardView.DistributionItem) {
			if let distval = CNDistribution(rawValue: val) {
				self.distribution = distval
			} else {
				cons.error(string: "Invalid raw value for distribution: \(val)\n")
			}
		} else {
			robj.setInt32Value(value: self.distribution.rawValue, forProperty: KMCardView.DistributionItem)
		}
		/* Add listner: distribution */
		robj.addObserver(forProperty: KMCardView.DistributionItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMCardView.DistributionItem) {
				if let distval = CNDistribution(rawValue: val) {
					CNExecuteInMainThread(doSync: false, execute: {
						self.distribution = distval
					})
				} else {
					cons.error(string: "Invalid raw value for distribution: \(val)\n")
				}
			}
		})

		/* Set initial value for index */
		robj.setInt32Value(value: Int32(self.currentIndex), forProperty: KMCardView.IndexItem)
		robj.addObserver(forProperty: KMCardView.IndexItem, callback: {
			(_ param: Any) -> Void in
			if let val = robj.int32Value(forProperty: KMCardView.IndexItem) {
				if self.currentIndex != val {
					CNExecuteInMainThread(doSync: false, execute: {
						if !super.setIndex(index: Int(val)) {
							cons.error(string: "Failed to update index of card: \(val)")
						}
					})
				}
			}
		})
		robj.addScriptedPropertyName(name: KMCardView.IndexItem)
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
		vst.visit(cardView: self)
	}
}

