//
//  AssetListContract.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

enum AssetListContract {
    enum SectionType: Hashable {
        case type
    }
    
    struct Section: Hashable {
        let type: SectionType
        let cells: [Cell]
    }
    
    enum Cell {
        case cell
    }
}
