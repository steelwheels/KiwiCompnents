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
	static let AxisItem		= CNAxis.typeName
	static let AlignmentItem	= CNAlignment.typeName
	static let DistributionItem	= CNDistribution.typeName

	private var mReactObject:	AMBReactObject?
	private var mContext:		KEContext?
	private var mEnvironment:	CNEnvironment?

	public var reactObject: AMBReactObject 	{ get { return getProperty(mReactObject)	}}
	public var context: KEContext 		{ get { return getProperty(mContext)		}}
	public var environment: CNEnvironment	{ get { return getProperty(mEnvironment)	}}

	public init(){
		mReactObject	= nil
		mContext	= nil
		mEnvironment	= nil
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 188, height: 21)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 32)
		#endif
		super.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		mReactObject	= nil
		mContext	= nil
		mEnvironment	= nil
		super.init(coder: coder)
	}

	public func setup(reactObject robj: AMBReactObject, context ctxt: KEContext, processManager pmgr: CNProcessManager, environment env: CNEnvironment) -> NSError? {
		mReactObject	= robj
		mContext	= ctxt
		mEnvironment	= env

		/* Sync initial value: axis */
		if let val = robj.getIntProperty(forKey: KMStackView.AxisItem) {
			if let axisval = CNAxis(rawValue: Int32(val)) {
				self.axis = axisval
			} else {
				CNLog(logLevel: .error, message: "Invalid raw value for axis: \(val)")
			}
		} else {
			robj.set(key: KMStackView.AxisItem, intValue: Int(self.axis.rawValue))
		}
		/* Add listner: axis */
		robj.addCallbackSource(forProperty: KMStackView.AxisItem, callbackFunction: {
			(_ val: Any) -> Void in
			if let val = robj.getIntProperty(forKey: KMStackView.AxisItem) {
				if let axisval = CNAxis(rawValue: Int32(val)) {
					self.axis = axisval
				} else {
					CNLog(logLevel: .error, message: "Invalid raw value for axis: \(val)")
				}
			}
		})

		/* Sync initial value: alignment */
		if let val = robj.getIntProperty(forKey: KMStackView.AlignmentItem) {
			if let alignval = CNAlignment(rawValue: Int32(val)) {
				self.alignment = alignval
			} else {
				CNLog(logLevel: .error, message: "Invalid raw value for alignment: \(val)")
			}
		} else {
			robj.set(key: KMStackView.AlignmentItem, intValue: Int(self.alignment.rawValue))
		}
		/* Add listner: alignment */
		robj.addCallbackSource(forProperty: KMStackView.AlignmentItem, callbackFunction: {
			(_ val: Any) -> Void in
			if let val = robj.getIntProperty(forKey: KMStackView.AxisItem) {
				if let alignval = CNAlignment(rawValue: Int32(val)) {
					self.alignment = alignval
				} else {
					CNLog(logLevel: .error, message: "Invalid raw value for alignment: \(val)")
				}
			}
		})

		/* Sync initial value: distribution */
		if let val = robj.getIntProperty(forKey: KMStackView.DistributionItem) {
			if let distval = CNDistribution(rawValue: Int32(val)) {
				self.distribution = distval
			} else {
				CNLog(logLevel: .error, message: "Invalid raw value for distribution: \(val)")
			}
		} else {
			robj.set(key: KMStackView.DistributionItem, intValue: Int(self.distribution.rawValue))
		}
		/* Add listner: distribution */
		robj.addCallbackSource(forProperty: KMStackView.DistributionItem, callbackFunction: {
			(_ val: Any) -> Void in
			if let val = robj.getIntProperty(forKey: KMStackView.DistributionItem) {
				if let distval = CNDistribution(rawValue: Int32(val)) {
					self.distribution = distval
				} else {
					CNLog(logLevel: .error, message: "Invalid raw value for axis: \(val)")
				}
			}
		})

		return nil
	}

	public var children: Array<AMBComponent> {
		get {
			var views: Array<AMBComponent> = []
			for subview in self.arrangedSubviews() {
				if let comp = subview as? AMBComponent {
					views.append(comp)
				}
			}
			return views
		}
	}

	public func addChild(component comp: AMBComponent) {
		if let view = comp as? KCView {
			super.addArrangedSubView(subView: view)
		} else {
			let cname = comp.reactObject.frame.className
			CNLog(logLevel: .error, message: "Unknown object: class=\(cname)")
		}
	}

	public func accept(visitor vst: KMVisitor) {
		vst.visit(stackView: self)
	}

	public func toText() -> CNTextSection {
		return reactObject.toText()
	}
}

