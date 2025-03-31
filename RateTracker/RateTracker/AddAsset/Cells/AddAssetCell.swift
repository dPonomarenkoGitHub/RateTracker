//
//  AddAssetCell.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import UIKit
import Reusable

final class AddAssetCell: UITableViewCell, NibReusable {
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var iconView: UIImageView!
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        containerView.backgroundColor = highlighted ? .systemGray5 : .white
    }
    
    func setup(with model: AddAssetContract.AssetModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        iconView.isHidden = !model.isSelected
    }
}
