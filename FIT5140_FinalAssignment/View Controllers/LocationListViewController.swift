//
//  LocationListViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 2/11/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class LocationListViewController: UIViewController {

    var locations: [Location] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // handle the data from the firebase
        
        // assign to the list
    }
    
    
}

extension LocationListViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location = locations[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationListCell") as! LocationListCell
        
        return cell
    }
}
