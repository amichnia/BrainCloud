//
//  Array+Extensions.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 02/07/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

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

// MARK: - Array convenience map extended
extension Array {
    
    /**
     Works like map - but ommits nil values. Returns new Array containing of these mapping results, which returned non nil values.
     
     - parameter transform: Mapping closure
     
     - throws: Error of mapping if provided in closure
     
     - returns: Array containing of these mapping results, which returned non nil values
     */
    public func mapExisting<T>(transform: (Array.Iterator.Element) throws -> T?) rethrows -> [T] {
        return try self.reduce([T]()) { (array, element) -> [T] in
            if let mappedElement = try transform(element) {
                return array + [mappedElement]
            }
            else {
                return array
            }
        }
    }
    
}
