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
    var coordinate: CLLocationCoordinate2D
    
    init(lat: Double, long: Double) {
        
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}
