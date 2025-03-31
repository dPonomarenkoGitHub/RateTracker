//
//  AddAssetContract.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

enum AddAssetContract {
    enum Cell: Hashable {
        case asset(AssetModel)
    }
    
    struct AssetModel: Hashable {
        let title: String
        let subtitle: String
        let isSelected: Bool
    }
}
