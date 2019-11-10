//
//  FirebaseController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 31/10/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import MapKit

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var tripsRef: CollectionReference?
    var tripsList: [Trip]
    
    override init() {
        // To use Firebase in our application we first must run the FirebaseApp configure method
        // FirebaseApp.configure()
        // We call auth and firestore to get access to these frameworks
        authController = Auth.auth()
        database = Firestore.firestore()
        tripsList = [Trip]()
        
        super.init()
        setUpListeners()
    }
    
    func setUpListeners() {
        // reference to current login user
        let currentUser = authController.currentUser?.uid
        let currentUserRef = database.collection("users").document(currentUser!)
        
        tripsRef = currentUserRef.collection("trips")
        
        tripsRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                return
            }
            self.parseTripsDataSnapshot(snapshot: querySnapshot!)
        }
    }
    
    /**
     Fetch data from the database based on the login user. Append the trips into the tripsList.
     When the trips in the database is changing, the tripsList will be updated.
     **/
    func parseTripsDataSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in

            let documentRef = change.document.documentID

            if change.type == .added {
                let newTripData = Trip()
                newTripData.tripName = documentRef
                newTripData.startTime = (change.document.data()["startTime"] as! String)
                newTripData.endTime = (change.document.data()["endTime"] as! String)
                
                let pointsRef = change.document.reference.collection("points")
                
                pointsRef.getDocuments() { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        // For each point inside each trip, append its locations to the [Location] array in the newTripData.
                        for document in querySnapshot!.documents {
                            let lat = (document.data()["latitude"] as! NSString).doubleValue
                            let long = (document.data()["longitude"] as! NSString).doubleValue
                            let timeStamp = document.data()["timeStamp"] as! String
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            
                            let newLocation = Location(title: document.documentID, subTitle: timeStamp, coordinate: coordinate)
                            newTripData.locations?.append(newLocation)
                        }
                    }
                }
                tripsList.append(newTripData)
            }
            
            if change.document.data().isEmpty == false {
                // Listen to the databse if any changes or adding is made, update the tripList
                if change.type == .modified || change.type == .added {
                    let index = getTripIndexByID(reference: documentRef)!
                    tripsList[index].tripName = documentRef
                }
            }
            
            // Listen to the databse if any deletion is made, update the tripList
            if change.type == .removed {
                if let index = getTripIndexByID(reference: documentRef) {
                    tripsList.remove(at: index)
                }
            }
        }

        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.tripsData || listener.listenerType == ListenerType.all {
                listener.onTripsChange(change: .update, tripsList: tripsList)
            }
        }
    }
    
    //get the index by ID
    func getTripIndexByID(reference: String) -> Int? {
        for tripData in tripsList {
            if(tripData.tripName == reference) {
                return tripsList.firstIndex(of: tripData)
            }
        }
        return nil
    }
    
    func deleteTrip(selectedTrip: Trip) {
        tripsRef?.document(selectedTrip.tripName!).delete()
    }
    
    func addListener(listener: DatabaseListener) {

        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.tripsData || listener.listenerType == ListenerType.all {
            
            listener.onTripsChange(change: .update, tripsList: tripsList)
            
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}
