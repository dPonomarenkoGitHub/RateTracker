//
//  AssetListContract.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

enum AssetListContract {
    enum Cell: Hashable {
        case asset(Model)
    }
    
    struct Model: Hashable {
        let title: String
        let subtitle: String
        let rate: String?
    }
}
