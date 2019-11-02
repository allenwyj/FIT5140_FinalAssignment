//
//  Location.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 2/11/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import MapKit

class Location: NSObject, MKAnnotation {
    //var image: UIImage
    var title: String?
    var subTitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, subTitle: String, coordinate: CLLocationCoordinate2D) {
        //self.image = image
        self.title = title
        self.subTitle = subTitle
        self.coordinate = coordinate
    }
}
