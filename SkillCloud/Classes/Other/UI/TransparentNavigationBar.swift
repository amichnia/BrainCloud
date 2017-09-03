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
