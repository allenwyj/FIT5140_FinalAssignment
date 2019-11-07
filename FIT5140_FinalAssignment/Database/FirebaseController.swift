//
//  FirebaseController.swift
//  assignment2
//
//  Created by Yujie Wu on 30/9/19.
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
    //var currentValuesRef: CollectionReference?
    var tripsList: [Trip]
    //var currentValueDataList: [CurrentValue]
    
    override init() {
        // To use Firebase in our application we first must run the FirebaseApp configure method
        // FirebaseApp.configure()
        // We call auth and firestore to get access to these frameworks
        authController = Auth.auth()
        database = Firestore.firestore()
        tripsList = [Trip]()
        //currentValueDataList = [CurrentValue]()
        
        super.init()
        
        // This will START THE PROCESS of signing in with an anonymous account
        // The closure will not execute until its recieved a message back which can be any time later
//        authController.signInAnonymously() { (authResult, error) in
//            guard authResult != nil else {
//                fatalError("Firebase authentication failed")
//            }
//            // Once we have authenticated we can attach our listeners to the firebase firestore
//            self.setUpListeners()
//        }
        
        
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
    
//    func getImageFromFireStorage() {
//        let storageRef = Storage.storage().reference()
//        storageRef.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//            if let data = data {
//                
//            }
//        }
//    }
    
    func parseTripsDataSnapshot(snapshot: QuerySnapshot) {
        
        snapshot.documentChanges.forEach { change in

            let documentRef = change.document.documentID
            
            // NOTE: Adding data from raspberry pi need to add the document first, then crate the sub-collection
            if change.type == .added {
                let newTripData = Trip()
                newTripData.tripName = documentRef
                
                let pointsRef = change.document.reference.collection("points")
                
                pointsRef.getDocuments() { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
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
                
                if change.type == .modified || change.type == .added {
                    let index = getTripIndexByID(reference: documentRef)!
                    tripsList[index].tripName = documentRef
                    print("############\(tripsList.count)")
                    //tripsList[index].locations = points
                }
            }
            
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
        print("listener removed")
        listeners.removeDelegate(listener)
    }
}
