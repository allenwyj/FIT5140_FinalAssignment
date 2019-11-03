//
//  Trip.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 3/11/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class Trip: NSObject {
    var tripName: String?
    var locations: [Location]?
    
    override init() {
        tripName = ""
        locations = []
    }
    
    init(tripName: String, points: [Location]) {
        self.tripName = tripName
        self.locations = points
    }
}
