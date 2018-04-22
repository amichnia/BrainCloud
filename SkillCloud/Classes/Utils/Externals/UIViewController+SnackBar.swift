import UIKit
import DRNSnackBar

// MARK: - Snack bar support
extension UIViewController {
    func showSnackBarMessage(_ message: String){
        (DRNSnackBar.makeText(message) as AnyObject).show()
    }
}
