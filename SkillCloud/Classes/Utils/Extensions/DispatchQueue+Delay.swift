import Foundation


// MARK: - Delay
extension DispatchQueue {

    static func delay(_ delay:Double, closure: @escaping ()->()) {
        DispatchQueue.main.delay(delay, closure: closure)
    }

    func delay(_ delay:Double, closure: @escaping ()->()) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
}

