import SpriteKit

// MARK: - User interaction with nodes
protocol TranslatableNode {
    var position: CGPoint { get set }
    var originalPosition: CGPoint { get set }
}

protocol ScalableNode {
    var currentScale: CGFloat { get set }
    var originalScale: CGFloat { get set }
}

extension ScalableNode {
    mutating func applyScale(_ scale: CGFloat) -> CGFloat {
        let minScale: CGFloat = 0.5
        let maxScale: CGFloat = 2.0
        self.currentScale =  max(0.5, min(2.0, self.originalScale + scale))
        return (self.currentScale - minScale) / (maxScale - minScale)
    }
    
    mutating func persistScale() {
        self.originalScale = self.currentScale
    }
}

