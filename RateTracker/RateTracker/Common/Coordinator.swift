//
//  Coordinator.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//
import UIKit

enum CoordinatorEnvironment {
    case phone
    case pad
}

enum CoordinatorEnvironmentTraits {
    case narrow
    case wide
}

protocol Coordinator {
    var environment: CoordinatorEnvironment { get }

    var environmentTraits: CoordinatorEnvironmentTraits { get }
    
    func popupPresentationContext() -> UIViewController?
}

extension Coordinator {
    var environmentTraits: CoordinatorEnvironmentTraits {
        if environment == .phone {
            return .narrow
        } else {
            if let root = UIWindow.main {
                let contentWidth = Int(root.frame.width - 270)
                return (contentWidth / 2 >= 350) ? .wide : .narrow
            } else {
                return .narrow
            }
        }
    }
}

extension UIWindow {
    static var main: UIWindow? {
        if let window = UIApplication.shared.delegate?.window {
            return window
        } else {
            return nil
        }
    }
}
