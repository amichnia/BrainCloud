import Foundation
import MRProgress


extension MRProgressOverlayView {
    
    static func show() {
        guard let window = UIApplication.shared.delegate?.window else {
            return
        }
        
        MRProgressOverlayView.showOverlayAdded(to: window, animated: true)
    }
    
    static func hide() {
        guard let window = UIApplication.shared.delegate?.window else {
            return
        }
        
        MRProgressOverlayView.dismissAllOverlays(for: window, animated: true)
    }
    
}
