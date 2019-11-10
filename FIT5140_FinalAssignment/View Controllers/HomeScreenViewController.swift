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
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        getUserName()
        setTimerToCheckFirestore(listenField: "currentLocation")
        setTimerToCheckFirestore(listenField: "statusCheck")
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    /**
     Get the current login user name
     **/
    func getUserName() {
        let userAuth = Auth.auth().currentUser
        let uid = userAuth!.uid
        let currentUserRef = database.collection("users").document(uid)

        currentUserRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let userName = document.data()!["firstName"] as! String
                self.nameLabel.text = "Welcome, \(userName)"
            } else {
                print("Document does not exist")
            }
        }
    }
    
    /**
     Scheduling timer to Call the function "checkAlertValue" with the interval of 2 seconds
     **/
    func setTimerToCheckFirestore(listenField: String) {
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
    
    /**
     Get the safety status from the database, and change the image and text based on the the value ('safe', 'stolen')
     **/
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
    
    /**
     The method is to get the current location of the car, it will fetch the last update value from the firebase
     and set to the text label.
     **/
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
                
                var currentCarLocation = CLLocation()
                currentCarLocation = CLLocation(latitude: lat, longitude: long)
                self.showAddress(currentCarLocation: currentCarLocation, updateTime: time)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    /**
     This method is to show the current car location address by passing CLLocation point.
     **/
    func showAddress(currentCarLocation: CLLocation, updateTime: String) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(currentCarLocation) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            if let _ = error {
                return
            }
            
            guard let placemark = placemarks?.first else {
                return
            }
            
            // if no value, shows blank
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            let suburbName = placemark.locality ?? ""
            let cityName = placemark.administrativeArea ?? ""
            
            DispatchQueue.main.async {
                self.locationLabel.text = "\(streetNumber) \(streetName) \(suburbName) \(cityName)"
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
