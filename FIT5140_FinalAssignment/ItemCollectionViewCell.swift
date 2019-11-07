//
//  ItemCollectionViewCell.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 7/11/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var selectIcon: UIImageView!
    @IBOutlet weak var selectIndicator: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override var isHighlighted: Bool {
        didSet {
            selectIndicator.isHidden = !isHighlighted
            
        }
    }
    
    // When the select mode is on, it will show the icon and the selectIndicator
    override var isSelected: Bool {
        didSet {
            selectIndicator.isHidden = !isSelected
            selectIcon.isHidden = !isSelected
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
