//
//  Then.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import UIKit

protocol Then {}

extension Then where Self: Any {
    func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }

    func `do`(_ block: (Self) throws -> Void) rethrows {
        try block(self)
    }
}

extension Then where Self: AnyObject {
    func then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
}

extension NSObject: Then {}
extension CGPoint: Then {}
extension CGRect: Then {}
extension CGSize: Then {}
extension CGVector: Then {}
extension Array: Then {}
extension Dictionary: Then {}
extension Set: Then {}
extension UIEdgeInsets: Then {}
extension UIOffset: Then {}
extension UIRectEdge: Then {}
extension URLRequest: Then {}
extension URLComponents: Then {}
extension JSONEncoder: Then {}
extension JSONDecoder: Then {}
