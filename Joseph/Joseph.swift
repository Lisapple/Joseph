//
//  Joseph.swift
//  Joseph
//
//  Created by Max on 10/06/2017.
//  Copyright © 2017 Lisacintosh. All rights reserved.
//

import UIKit

// MARK: - Layout Priority Operator

infix operator ~: TernaryPrecedence // More precedent than assignment

/// Set layout priority.
/// Only supported for LengthConstraint, PositionConstraint and RatioConstraint.
///
/// - Parameters:
///     - lhs: The constraint to change
///     - rhs: the priority to apply
/// Usage:
/// ```
/// label.width = view.width ~ 249
/// ```
func ~<T : LayoutConstraint>(lhs: T, rhs: Int) -> T {
	var constraint = lhs
	constraint.priority = Float(rhs)
	return constraint
}

// MARK: - LayoutAxis

struct LayoutAxis {
	
	var axis: UILayoutConstraintAxis = .horizontal
	var view: UIView
}

extension UIView {
	
	/// The horizontal axis.
	var x: LayoutAxis {
		return LayoutAxis(axis: .horizontal, view: self)
	}
	
	/// The vertical axis.
	var y: LayoutAxis {
		return LayoutAxis(axis: .vertical, view: self)
	}
}

infix operator >~<: AssignmentPrecedence

/// Set the priority on which a view resists to be smaller that its content (resistance to compression).
/// On a lower priority, meaning lower resistance, the view would accept to shrink.
/// Default to `required`, the view won't shrink. see `UILayoutPriority` for correct value for priority.
/// Usage:
/// ```
/// view >~< 249 // Low resistance to shrink
/// ```
func >~<(lhs: LayoutAxis, rhs: Int) {
	lhs.view.setContentCompressionResistancePriority(Float(rhs), for: lhs.axis)
}

infix operator <~>: AssignmentPrecedence

/// Set the priority on which a view resists to be bigger that its content (resistance to hugging).
/// On a lower priority, meaning lower resistance, the view would accept to expand.
/// Default to `required`, the view won't expand. see `UILayoutPriority` for correct value for priority.
/// Usage:
/// ```
/// view <~> 751 // High resistance to expand
/// ```
func <~>(lhs: LayoutAxis, rhs: Int) {
	lhs.view.setContentHuggingPriority(Float(rhs), for: lhs.axis)
}

// MARK: - LayoutConstraint

protocol LayoutConstraint {
	
	/// Should be initialized to 0.
	var constant: CGFloat { get set }
	
	/// Should be initialized to 1.
	var multiplier: CGFloat { get set }
	
	/// Should be initialized to `.notAnAttribute` if no view set.
	var attribute: NSLayoutAttribute { get }
	
	/// The default value is `UILayoutPriorityRequired`.
	var priority: Float? { get set }
}

/// Adds a specific distance in points to a layout constraint.
/// Usage:
/// ```
/// view1.left = view2.leftMargin + 20
/// ```
func +<T : LayoutConstraint>(lhs: T, rhs: CGFloat) -> T {
	var constraint = lhs
	constraint.constant += rhs
	return constraint
}

/// Substracts a specific distance in points to a layout constraint.
/// Usage:
/// ```
/// view1.left = view2.leftMargin - 20
/// ```
func -<T : LayoutConstraint>(lhs: T, rhs: CGFloat) -> T {
	var constraint = lhs
	constraint.constant -= rhs
	return constraint
}

/// Multiplies a layout constraint with by a factor.
/// Usage:
/// ```
/// view1.top = view2.top * 2
/// ```
func *<T: LayoutConstraint>(lhs: T, rhs: CGFloat) -> T {
	var constraint = lhs
	constraint.multiplier = rhs
	return constraint
}
func *<T: LayoutConstraint>(lhs: CGFloat, rhs: T) -> T { return rhs * lhs }

infix operator ×: MultiplicationPrecedence

/// see `*` operator.
func ×<T: LayoutConstraint>(lhs: T, rhs: CGFloat) -> T { return lhs * rhs }
func ×<T: LayoutConstraint>(lhs: CGFloat, rhs: T) -> T { return rhs * lhs }

func /<T: LayoutConstraint>(lhs: T, rhs: CGFloat) -> T {
	assert(rhs != 0)
	return lhs * (1 / rhs)
}

// MARK: - LengthConstraint

struct LengthConstraint: LayoutConstraint {
	
	var constant: CGFloat = 0
	var multiplier: CGFloat = 1
	
	private(set) var view: UIView?
	private(set) var attribute: NSLayoutAttribute = .notAnAttribute
	
	var priority: Float?
	
	init(view: UIView?, attribute: NSLayoutAttribute, multiplier: CGFloat = 1, constant: CGFloat = 0) {
		self.view = view
		self.attribute = attribute
		self.constant = constant
		self.multiplier = multiplier
	}
}

extension LengthConstraint: ExpressibleByIntegerLiteral {
	
	typealias IntegerLiteralType = Int
	
	init(integerLiteral value: Int) {
		constant = CGFloat(value)
	}
}

extension LengthConstraint: ExpressibleByFloatLiteral {
	
	typealias FloatLiteralType = Double
	
	init(floatLiteral value: LengthConstraint.FloatLiteralType) {
		constant = CGFloat(value)
	}
}

/// Same that setting a "less than or equal" relation.
/// One of `lhs` or `rhs` must be a view layout property; Assert if not.
func <=(lhs: LengthConstraint, rhs: LengthConstraint) {
	assert(lhs.view != nil || rhs.view != nil,
	       "Invalid constraint with two literals; At least one of the two items must have a view.")
	
	if let view = lhs.view {
		view.add(constraint: rhs, to: lhs.attribute, relatedBy: .lessThanOrEqual) }
	else if let view = rhs.view {
		view.add(constraint: lhs, to: rhs.attribute, relatedBy: .lessThanOrEqual) }
}

/// Same that setting a "greater than or equal" relation.
/// One of `lhs` or `rhs` must be a view layout property; Assert if not.
func >=(lhs: LengthConstraint, rhs: LengthConstraint) {
	assert(lhs.view != nil || rhs.view != nil,
	       "Invalid constraint with two literals; At least one of the two items must have a view.")
	
	if let view = lhs.view {
		view.add(constraint: rhs, to: lhs.attribute, relatedBy: .greaterThanOrEqual) }
	else if let view = rhs.view {
		view.add(constraint: lhs, to: rhs.attribute, relatedBy: .greaterThanOrEqual) }
}

extension LengthConstraint {
	
	/// Specify a range of allowed values for a length.
	///
	/// Usage:
	/// ```
	/// view.width.in(50...120)
	/// // Same that:
	/// 50 <= view.width; view.width <= 120
	/// ```
	func `in`(_ range: ClosedRange<Double>) {
		let minBound = min(range.lowerBound, range.upperBound)
		let lower = LengthConstraint(floatLiteral: minBound)
		let maxBound = max(range.lowerBound, range.upperBound)
		let upper = LengthConstraint(floatLiteral: maxBound)
		lower <= self; self <= upper
	}
}

extension UIView {
	
	/// Distance from left to right; excluding margins.
	var width: LengthConstraint {
		get { return LengthConstraint(view: self, attribute: .width) }
		set { add(constraint: newValue, to: .width) }
	}
	
	/// Distance from top to bottom; excluding margins.
	var height: LengthConstraint {
		get { return LengthConstraint(view: self, attribute: .height) }
		set { add(constraint: newValue, to: .height) }
	}
}

// MARK: - PositionConstraint

struct PositionConstraint: LayoutConstraint {
	
	var constant: CGFloat = 0
	var multiplier: CGFloat = 1
	
	private(set) var view: UIView
	private(set) var attribute: NSLayoutAttribute
	
	var priority: Float?
	
	init(view: UIView, attribute: NSLayoutAttribute, multiplier: CGFloat = 1, constant: CGFloat = 0) {
		self.view = view
		self.attribute = attribute
		self.constant = constant
		self.multiplier = multiplier
	}
}

/// Same that setting a "less than or equal" relation.
func <=(lhs: PositionConstraint, rhs: PositionConstraint) {
	lhs.view.add(constraint: rhs, to: lhs.attribute, relatedBy: .lessThanOrEqual)
}

/// Same that setting a "greater than or equal" relation.
func >=(lhs: PositionConstraint, rhs: PositionConstraint) {
	lhs.view.add(constraint: rhs, to: lhs.attribute, relatedBy: .greaterThanOrEqual)
}

extension UIView {
	
	/// see NSLayoutAttribute.top
	var top: PositionConstraint {
		get { return PositionConstraint(view: self, attribute: .top) }
		set { add(constraint: newValue, to: .top) }
	}
	
	/// see NSLayoutAttribute.topMargin
	var topMargin: PositionConstraint {
		get { return PositionConstraint(view: self, attribute: .topMargin) }
		set { add(constraint: newValue, to: .topMargin) }
	}
	
	/// see NSLayoutAttribute.left
	var left: PositionConstraint {
		get { return PositionConstraint(view: self, attribute: .left) }
		set { add(constraint: newValue, to: .left) }
	}
	
	/// see NSLayoutAttribute.leftMargin
	var leftMargin: PositionConstraint {
		get { return PositionConstraint(view: self, attribute: .leftMargin) }
		set { add(constraint: newValue, to: .leftMargin) }
	}
	
	/// see NSLayoutAttribute.right
	var right: PositionConstraint {
		get { return PositionConstraint(view: self, attribute: .right) }
		set { add(constraint: newValue, to: .right) }
	}
	
	/// see NSLayoutAttribute.rightMargin
	var rightMargin: PositionConstraint {
		get { return PositionConstraint(view: self, attribute: .rightMargin) }
		set { add(constraint: newValue, to: .rightMargin) }
	}
	
	/// see NSLayoutAttribute.bottom
	var bottom: PositionConstraint {
		get { return PositionConstraint(view: self, attribute: .bottom) }
		set { add(constraint: newValue, to: .bottom) }
	}
	
	/// see NSLayoutAttribute.bottomMargin
	var bottomMargin: PositionConstraint {
		get { return PositionConstraint(view: self, attribute: .bottomMargin) }
		set { add(constraint: newValue, to: .bottomMargin) }
	}
	
	/// see NSLayoutAttribute.centerX
	var centerX: PositionConstraint {
		get { return PositionConstraint(view: self, attribute: .centerX) }
		set { add(constraint: newValue, to: .centerX) }
	}
	
	/// see NSLayoutAttribute.centerY
	var centerY: PositionConstraint {
		get { return PositionConstraint(view: self, attribute: .centerY) }
		set { add(constraint: newValue, to: .centerY) }
	}
}

// MARK: - LayoutConstraintGroup

protocol LayoutConstraintGroup {
	
	/// The horizontal and vertical offset or margins.
	var constants: UIOffset { get set }
	
	/// The view related to constraint.
	var view: UIView { get }
}

// MARK: - CenterConstraint

struct CenterConstraint: LayoutConstraintGroup {
	
	var constants: UIOffset = .zero
	
	private(set) var view: UIView
}

extension UIView {
	
	/// The center of the view; independly of margins.
	var middle: CenterConstraint {
		get { return CenterConstraint(constants: .zero, view: self) }
		set {
			let superview = commonSuperview(with: newValue.view)
			superview.addConstraints([
				NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal,
				                   toItem: newValue.view, attribute: .centerX, multiplier: 1, constant: newValue.constants.vertical),
				NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal,
				                   toItem: newValue.view, attribute: .centerY, multiplier: 1, constant: newValue.constants.horizontal),
			])
		}
	}
}

// MARK: - EdgesConstraint

struct EdgesConstraint: LayoutConstraintGroup {
	
	var constants: UIOffset = .zero
	
	private(set) var view: UIView
	
	/// True to specify constraints related to margins.
	private(set) var usesMargins: Bool = false
}

/// Set center offset to left-bottom direction; or inset (shrink) edges
func +<T : LayoutConstraintGroup>(lhs: T, rhs: CGFloat) -> T {
	var constraint = lhs
	constraint.constants = UIOffset(horizontal: rhs, vertical: rhs)
	return constraint
}

/// Set center offset to right-top direction; or outset (expand) edges
func -<T : LayoutConstraintGroup>(lhs: T, rhs: CGFloat) -> T {
	return lhs + (-rhs)
}

/// Set center offset to left and/or bottom direction; or inset (shrink) vertical and/or horizontal edges
func +<T : LayoutConstraintGroup>(lhs: T, rhs: UIOffset) -> T {
	var constraint = lhs
	constraint.constants = rhs
	return constraint
}

/// Set center offset to right and/or top direction; or ouset (expand) vertical and/or horizontal edges
func -<T : LayoutConstraintGroup>(lhs: T, rhs: UIOffset) -> T {
	return lhs + UIOffset(horizontal: -rhs.horizontal, vertical: -rhs.vertical)
}

extension UIView {
	
	private func add(edgeConstraints edges: EdgesConstraint) {
		let superview = commonSuperview(with: edges.view)
		superview.addConstraints([
			NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal,
			                   toItem: edges.view, attribute: edges.usesMargins ? .topMargin : .top,
			                   multiplier: 1, constant: edges.constants.vertical),
			NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal,
			                   toItem: edges.view, attribute: edges.usesMargins ? .leftMargin : .left,
			                   multiplier: 1, constant: edges.constants.horizontal),
			NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal,
			                   toItem: edges.view, attribute: edges.usesMargins ? .rightMargin : .right,
			                   multiplier: 1, constant: -edges.constants.horizontal),
			NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal,
			                   toItem: edges.view, attribute: edges.usesMargins ? .bottomMargin : .bottom,
			                   multiplier: 1, constant: -edges.constants.vertical)
		])
	}
	
	/// The edges of the view, ignoring margins.
	var edges: EdgesConstraint {
		get { return EdgesConstraint(constants: .zero, view: self, usesMargins: false) }
		set { add(edgeConstraints: newValue) }
	}
	
	/// The edges of the view, in respect of margins.
	var margins: EdgesConstraint {
		get { return EdgesConstraint(constants: .zero, view: self, usesMargins: true) }
		set { add(edgeConstraints: newValue) }
	}
}

// MARK: - RatioConstraint

struct RatioConstraint: LayoutConstraint {
	
	var constant: CGFloat = 0
	var multiplier: CGFloat = 1
	
	private(set) var view: UIView?
	private(set) var attribute: NSLayoutAttribute = .notAnAttribute
	
	var priority: Float?
}

extension UIView {
	
	/// The ratio (float) is the proportion `width / height`.
	/// see `∶` custom operator.
	var ratio: CGFloat {
		get { return 1 }
		set { addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal,
		                                       toItem: self, attribute: .height, multiplier: newValue, constant: 0)) }
	}
}

infix operator ∶: MultiplicationPrecedence

/// Operator for ratio, with value `width∶height`; `1∶2` is the same that `1.0 / 2.0`, or `0.5`.
/// Note: `∶` is the UTF-8 character, not the ASCII `:`.
func ∶(lhs: Int, rhs: Int) -> CGFloat {
	return CGFloat(lhs) / CGFloat(rhs)
}

// MARK: - View utilities
extension UIView {
	
	/// Returns all superviews from self to root superview; including self.
	private var superviews: [UIView] {
		var superview: UIView = self
		var superviews: [UIView] = []
		while let view = superview.superview {
			superviews.append(view)
			superview = view
		}
		return superviews
	}
	
	/// Returns a common superview from self and `view`; asserts if no such view.
	fileprivate func commonSuperview(with view: UIView) -> UIView {
		let superviews1 = [self] + self.superviews
		let superviews2 = [view] + view.superviews
		let superview = superviews1.first { superviews2.contains($0) }
		assert(superview != nil, "The two views of this constraint must descend from a common superview.")
		return superview!
	}
	
	fileprivate func add(constraint c: PositionConstraint, to attribute: NSLayoutAttribute, relatedBy relation: NSLayoutRelation = .equal) {
		let view = commonSuperview(with: c.view)
		let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation,
		                                    toItem: c.view, attribute: c.attribute,
		                                    multiplier: c.multiplier, constant: c.constant)
		constraint.priority = c.priority ?? UILayoutPriorityRequired
		view.addConstraint(constraint)
	}
	
	fileprivate func add(constraint c: LengthConstraint, to attribute: NSLayoutAttribute, relatedBy relation: NSLayoutRelation = .equal) {
		var view: UIView = self
		if let constraintView = c.view {
			view = commonSuperview(with: constraintView)
		}
		let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation,
		                                    toItem: c.view, attribute: c.attribute,
		                                    multiplier: c.multiplier, constant: c.constant)
		constraint.priority = c.priority ?? UILayoutPriorityRequired
		view.addConstraint(constraint)
	}
}
