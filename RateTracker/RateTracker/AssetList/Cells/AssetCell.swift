//
//  AssetCell.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import UIKit
import Reusable

final class AssetCell: UITableViewCell, NibReusable {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var rateLabel: UILabel!
    @IBOutlet private var containerView: UIView!
        
    func setup(with model: AssetListContract.Model) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        rateLabel.attributedText = model.rate
        rateLabel.isHidden = model.rate == nil
    }
}
