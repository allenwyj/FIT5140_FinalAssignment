//
//  LocationListCell.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 2/11/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class LocationListCell: UITableViewCell {

    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationCellLabel: UILabel!
    
    func setLocationCell (location: Location) {
        //locationImageView.image = location.image
        locationCellLabel.text = location.title
    }
    

}
