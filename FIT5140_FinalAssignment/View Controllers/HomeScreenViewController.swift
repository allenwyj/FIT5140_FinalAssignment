//
//  HomeScreenViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 10/11/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import Firebase
import MapKit

class HomeScreenViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    
    let database = Firestore.firestore()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupActivityIndicator()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        getUserName()
        setTimerToCheckFirestore(listenField: "currentLocation")
        setTimerToCheckFirestore(listenField: "statusCheck")
        
    }
    
    func getUserName() {
        let userAuth = Auth.auth().currentUser
        let uid = userAuth!.uid
        let currentUserRef = database.collection("users").document(uid)
        
        print("=================")
        print("User Id: \(uid)")
        print("=================")
        currentUserRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let userName = document.data()!["firstName"] as! String
                self.nameLabel.text = "Welcome, \(userName)"
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func setTimerToCheckFirestore(listenField: String) {
        // 0 is default, 1 is setting
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(checkAlertValue), userInfo: listenField, repeats: true)
    }
    
    @objc func checkAlertValue(sender: Timer) {
        if sender.userInfo as! String == "currentLocation" {
            getAlertDataFromFirebase()
        }
        if sender.userInfo as! String == "statusCheck" {
            getCarLocationFromFirestore()
        }
        
    }
    
    func getAlertDataFromFirebase() {
        let fieldName = "alert"
        let database = Firestore.firestore()
        let dbRef = database.collection("raspberryPiData").document("raspberryPi1")
        
        dbRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let status = document.data()![fieldName] as! String
                if status == "stolen" {
                    self.statusImage.image = UIImage(named: "stolen")
                    self.statusView.backgroundColor = UIColor.init(red: 255/255, green: 51/255, blue: 51/255, alpha: 1)
                } else {
                    self.statusImage.image = UIImage(named: "safe")
                    self.statusView.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
//    func updateTimeStamp(timeStamp: String) {
//        lastUpdateTime.text = "Last update: \(timeStamp)"
//    }
    
    func getCarLocationFromFirestore() {
        let db = Firestore.firestore()
        
        // Fetching data from currentValues in the raspberry pi collection
        //let carLocationRef = currentUserRef.collection("currentValues").document("currentLocation")
        let carLocationRef = db.collection("raspberryPiData").document("raspberryPi1")
        carLocationRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let currentLocation = document.data()!["currentLocation"] as! [String : Any]
                let lat = (currentLocation["latitude"] as! NSString).doubleValue
                let long = (currentLocation["longitude"] as! NSString).doubleValue
                let time = currentLocation["timeStamp"] as! String
                
                //self.updateTimeStamp(timeStamp: time)
                var currentCarLocation = CLLocation()
                currentCarLocation = CLLocation(latitude: lat, longitude: long)
                self.showAddress(currentCarLocation: currentCarLocation, updateTime: time)
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            } else {
                print("Document does not exist")
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    func showAddress(currentCarLocation: CLLocation, updateTime: String) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentCarLocation) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let _ = error {
                // TO DO:
                return
            }
            
            guard let placemark = placemarks?.first else {
                //TO DO:
                return
            }
            
            // if no value, shows blank
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            let suburbName = placemark.locality ?? ""
            let cityName = placemark.administrativeArea ?? ""
            
            DispatchQueue.main.async {
                self.locationLabel.text = "\(streetNumber), \(streetName) \(suburbName) \(cityName)"
                self.lastUpdateLabel.text = updateTime
            }
        }
    }
    
    func setupActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        self.view.addSubview(activityIndicator)
    }
    
    

}
