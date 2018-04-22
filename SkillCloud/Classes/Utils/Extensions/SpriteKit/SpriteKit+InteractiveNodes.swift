import SpriteKit

// MARK: - Sprite Kit interactive nodes
protocol NonInteractiveNode: class {
    var interactionNode: SKNode? { get }
}

extension NonInteractiveNode where Self : SKNode {
    var interactionNode: SKNode? {
        return self is InteractiveNode ? self : self.parent?.interactionNode
    }
}

protocol InteractiveNode: NonInteractiveNode { }

extension InteractiveNode where Self : SKNode {
    var interactionNode: SKNode? {
        return self
    }
}

extension SKNode: NonInteractiveNode {}
