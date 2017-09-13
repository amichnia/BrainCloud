import UIKit

extension UIBezierPath {
    convenience init(equilateralPolygonEdges n: Int, center: CGPoint = CGPoint.zero, radius: CGFloat, cornerRadius: CGFloat = 0) {
        assert(n >= 3, "Number of edges should be greater or equal 3 !!!")
        assert(cornerRadius < radius, "Corner radius should be less than radius !!!")

        let offset = Scalar.halfPi
        let radius = Scalar(radius)
        let cornerRadius = Scalar(cornerRadius)

        let verticeVector = Vector2(radius, 0).rotated(by: offset)
        let angle = Scalar.twoPi / Scalar(n)

        if cornerRadius <= 0 {
            self.init()
            let vertices = (0..<n).map { center + verticeVector.rotated(by: angle * Scalar($0)) }
            applyVertices(vertices)
        } else {
            let alpha = angle / 2
            let start = offset - alpha
            let end = offset + alpha
            let h = Scalar(cornerRadius / cos(alpha))
            let v = Vector2(h,0).rotated(by: offset)
            let arcCenter = center + (verticeVector - v)

            self.init(arcCenter: arcCenter, radius: cornerRadius, startAngle: start, endAngle: end, clockwise: true)
            applyArcs(n, center: center, angle: angle, radius: radius, cornerRadius: cornerRadius)
        }
    }

    private func applyVertices(_ vertices: [CGPoint]) {
        guard let first = vertices.first else {
            return
        }

        move(to: first)

        vertices.dropFirst().forEach(addLine(to:))
        close()
    }

    private func applyArcs(_ n: Int, center: CGPoint, angle: Scalar, radius R: CGFloat, cornerRadius r: CGFloat) {
        let offset = Scalar.halfPi
        let alpha = Scalar(angle / 2)
        let h = Scalar(r / cos(alpha))
        let verticeVector = Vector2(R, 0).rotated(by: offset)
        let v = Vector2(h,0).rotated(by: offset)

        func addArc(edge: Int, rounded: Bool = true) {
            let currentAngle = Scalar(edge) * angle

            guard rounded else {
                addLine(to: center + verticeVector.rotated(by: currentAngle))
                return
            }

            let start = offset + currentAngle - alpha
            let end = offset + currentAngle + alpha
            let arcCenter = center + (verticeVector - v).rotated(by: currentAngle)

            self.addArc(withCenter: arcCenter, radius: r, startAngle: start, endAngle: end, clockwise: true)
        }

        (1..<n).forEach { addArc(edge: $0) }
        close()
    }
}
