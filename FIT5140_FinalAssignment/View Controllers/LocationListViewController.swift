//
//  LocationListViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 2/11/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class LocationListViewController: UITableViewController, DatabaseListener {
    var listenerType = ListenerType.tripsData
    var trips: [Trip] = []
    weak var databaseController: DatabaseProtocol?

    // var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        // databaseController = FirebaseController()
        // ERROR: Adding to table view depends on how many times do user click Map
        
        // handle the data from the firebase
        
        // assign to the list
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        databaseController?.removeListener(listener: self)
    }
    
    func onTripsChange(change: DatabaseChange, tripsList: [Trip]) {
        trips = tripsList
        
        self.tableView.reloadData()
    }
    
    func onCurrentValuesChange(change: DatabaseChange, currentValueDataList: [CurrentValue]) {
        //
    }
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trip = trips[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationListCell") as! LocationListCell
        
        // TO DO: set trip info to the cell
        cell.locationCellLabel.text = trip.tripName
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let trip = trips[indexPath.row]
        
        performSegue(withIdentifier: "LocationListToTripViewSegue", sender: trip)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "LocationListToTripViewSegue" {
            let destVC = segue.destination as! TripViewController
            destVC.trip = sender as? Trip
        }
    }
    
}
