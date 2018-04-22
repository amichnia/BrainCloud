import Foundation

// MARK: - Array shifting
extension Array {
    func rotate(_ shift:Int) -> Array {
        var array = Array()
        if (self.count > 0) {
            array = self
            if (shift > 0) {
                for _ in 1...shift {
                    array.append(array.remove(at: 0))
                }
            }
            else if (shift < 0) {
                for _ in 1...abs(shift) {
                    array.insert(array.remove(at: array.count-1),at:0)
                }
            }
        }
        return array
    }
}

// MARK: - Array indexPath shorthand
extension Array {
    
    subscript(indexPath: IndexPath) -> Element {
        return self[indexPath.row]
    }
    
}

