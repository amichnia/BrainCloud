import Foundation


// MARK: - Custom operators
// MARK: - Optional assignment
infix operator ?=: AdditionPrecedence
public func ?=<T,U>(lhs: inout T, rhs: U?) {
    if let value = rhs {
        lhs = (value as! T)
    }
}
