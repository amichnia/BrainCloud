import UIKit

extension CGPoint {
    public func angle(with v: Vector2) -> Scalar {
        let w = Vector2(x,y)
        return w.angle(with: v)
    }

    public static func +(lhs: CGPoint, rhs: Vector2) -> CGPoint {
        return CGPoint(x: lhs.x + CGFloat(rhs.x), y: lhs.y + CGFloat(rhs.y))
    }
}
