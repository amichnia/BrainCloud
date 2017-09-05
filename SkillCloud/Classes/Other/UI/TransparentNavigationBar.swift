import UIKit

public class TransparentNavigationBar: UINavigationBar {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        self.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.isTranslucent = true
        self.shadowImage = UIImage()
        self.tintColor = .black
    }

    public override func setItems(_ items: [UINavigationItem]?, animated: Bool) {
        super.setItems(items, animated: animated)
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let _ = subviews.first(where: { $0.isUserInteractionEnabled && $0.point(inside: self.convert(point, to: $0), with: event) }) else {
            return false
        }

        return true
    }
}

extension UINavigationController {
    public func presentTransparentNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
    }

    public func resetTransparentNavigationBar() {
        navigationBar.setBackgroundImage(UINavigationBar.appearance().backgroundImage(for: UIBarMetrics.default), for: UIBarMetrics.default)
        navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
    }


}
