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

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var tripsRef: CollectionReference?
    var currentValuesRef: CollectionReference?
    var tripsList: [Trip]
    var currentValueDataList: [CurrentValue]
    
    override init() {
        // To use Firebase in our application we first must run the FirebaseApp configure method
        FirebaseApp.configure()
        // We call auth and firestore to get access to these frameworks
        authController = Auth.auth()
        database = Firestore.firestore()
        tripsList = [Trip]()
        currentValueDataList = [CurrentValue]()
        
        super.init()
        
        // This will START THE PROCESS of signing in with an anonymous account
        // The closure will not execute until its recieved a message back which can be any time later
        authController.signInAnonymously() { (authResult, error) in
            guard authResult != nil else {
                fatalError("Firebase authentication failed")
            }
            // Once we have authenticated we can attach our listeners to the firebase firestore
            self.setUpListeners()
        }
    }
    
    func setUpListeners() {
        // reference to current login user
        let currentUser = authController.currentUser?.uid
        let currentUserRef = database.collection("users").document(currentUser!)
        
        tripsRef = currentUserRef.collection("trips")
        
        currentValuesRef = database.collection("currentValues")
        
        tripsRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                
                return
            }
            self.parseTripsDataSnapshot(snapshot: querySnapshot!)
        }
        
        currentValuesRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                
                return
            }
            self.parseCurrentValuesDataSnapshot(snapshot: querySnapshot!)
        }
    }
    
    func parseTripsDataSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in

            //let documentRef = change.document.documentID
            let documentRef = change.document.documentID
            
            print("Firebase Before: \(tripsList.count)")
            if change.type == .added {
                let newTripData = Trip()
                newTripData.tripName = documentRef
                tripsList.append(newTripData)
                print("**********\(tripsList.count)")
            }
            print("Firebase After: \(tripsList.count)")

            if change.document.data().isEmpty == false {
//                var points = [Location]()
//                for point in change.document.data() {
//                    print(point)
//
//                }
                
                if change.type == .modified || change.type == .added {
                    let index = getTripIndexByID(reference: documentRef)!
                    tripsList[index].tripName = documentRef
                    print("############\(tripsList.count)")
                    //tripsList[index].locations = points
                }

                if change.type == .removed {
                    if let index = getTripIndexByID(reference: documentRef) {
                        tripsList.remove(at: index)
                    }
                }
            }
        }

        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.tripsData || listener.listenerType == ListenerType.all {
                print("invoke before: \(tripsList.count)")
                listener.onTripsChange(change: .update, tripsList: tripsList)
                print("invoke after: \(tripsList.count)")
            }
        }
    }
    
    func parseCurrentValuesDataSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in
            
            let documentRef = change.document.documentID
            let id = change.document.documentID
            
            // Firebase generates the new document then it modifies the document with putting fields.
            // The first step -> create a new document with document ID, listener will catch this change and start update the table,
            // The second step -> firebase modifies the fields of the new document, listener will catch this and go to .modified step.
            if change.type == .added {
                let newCurrentValueData = CurrentValue()
                newCurrentValueData.id = id
                currentValueDataList.append(newCurrentValueData)
            }
            
            // Therefore, this is for the second time updateing ( the new document will created in the first
            // updating with empty field, it won't go through this)
            if change.document.data().isEmpty == false {
                //let timeStamp = change.document.data()["timeStamp"] as! String
               
                
                // This is for modifying document data after updating in the firebase, and it's for putting values
                // into the new document that is sent by the server.
                if change.type == .modified || change.type == .added {
                    let index = 0
                    currentValueDataList[index].id = documentRef
                    //currentValueDataList[index].timeStamp = timeStamp
                    
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.currentValue || listener.listenerType == ListenerType.all {
                
                listener.onCurrentValuesChange(change: .update, currentValueDataList: currentValueDataList)
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
    
    func addListener(listener: DatabaseListener) {
        setUpListeners()
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.tripsData || listener.listenerType == ListenerType.all {
            print("addListener before: \(tripsList.count)")
            listener.onTripsChange(change: .update, tripsList: tripsList)
            print("addListener after: \(tripsList.count)")
        }
        
        
        if listener.listenerType == ListenerType.currentValue || listener.listenerType == ListenerType.all {
            listener.onCurrentValuesChange(change: .update, currentValueDataList: currentValueDataList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}
