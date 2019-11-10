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

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        databaseController?.removeListener(listener: self)
    }
    
    /**
     This method is to listen the tripsList changes. If there is a change, reload the tableview.
     **/
    func onTripsChange(change: DatabaseChange, tripsList: [Trip]) {
        trips = tripsList
        
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trip = trips[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationListCell") as! LocationListCell
        
        // set trip info on the cell
        let startTime = trip.startTime!
        let endTime = trip.endTime!
        cell.locationCellLabel.text = "Route Ref: \(trip.tripName!)"
        cell.locationCellTimeLabel.text = "From \(startTime) To \(endTime)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    /**
     This method is to send the trip through the segue.
     **/
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
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            databaseController?.deleteTrip(selectedTrip: trips[indexPath.row])

            tableView.reloadData()
        }
    }
}
