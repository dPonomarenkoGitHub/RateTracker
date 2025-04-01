//
//  UpdateStatusCell.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 01.04.2025.
//

import UIKit
import Reusable

final class UpdateStatusCell: UITableViewCell, NibReusable {
    @IBOutlet private var statusLabel: UILabel!
    
    func setup(with status: String) {
        statusLabel.text = status
    }
}
