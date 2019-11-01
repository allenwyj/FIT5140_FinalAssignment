//
//  User.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 1/11/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class User: NSObject {
    var firstName: String
    var lastName: String
    var uid: String
    
    override init() {
        uid = ""
        firstName = ""
        lastName = ""
    }
}
