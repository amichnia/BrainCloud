import Foundation
import MRProgress
import PromiseKit

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
    
    static func promiseHide() -> Promise<Void> {
        guard let window = UIApplication.shared.delegate?.window else {
            return Promise<Void>(value: ())
        }
        
        return Promise<Void>(resolvers: { success,_ in
            MRProgressOverlayView.dismissOverlay(for: window, animated: true, completion: { 
                success()
            })
        })
    }
    
}
