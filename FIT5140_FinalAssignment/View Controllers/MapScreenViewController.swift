//
//  MapScreenViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 1/11/19.
//  Reference From Sean Allen https://www.youtube.com/watch?v=WPpaAy73nJc
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class MapScreenViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var lastUpdateTime: UILabel!
    
    var locationManager = CLLocationManager()
    var userCurrentLocation: CLLocationCoordinate2D?
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationService()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        
        scheduledUpdateCurrentCarLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()

        timer.invalidate()
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /**
     This method is to check whether the location service is enable or not.
     **/
    func checkLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            checkLocationServiceAuthorization()
        } else {
            // notify to turn on
            displayMessage("Please turn on the location service in the Settings.", "Error")
        }
    }
    
    /**
     This method is to check whether the user grant the permission of using location for the app.
     **/
    func checkLocationServiceAuthorization() {
        let status = CLLocationManager.authorizationStatus()
        
        if  status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            
        } else if status == .denied {
            displayMessage("Please allow to use the location service.", "Error")
        } else {
            // restricted
            displayMessage("Please turn on the location service in the Settings.", "Error")
        }
    }
    
    /**
     This method is to zoom into user's current location.
     **/
    func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    func displayMessage(_ message: String, _ title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /**
     This method is to set the timer to check the car location.
     **/
    func scheduledUpdateCurrentCarLocation() {
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounting(){
        // remove annotation
        removeAnnotation()
        // TO DO: Check db
        getCarLocationFromFirestore()
    }
    
    /**
     This method is to add the car marker on the map.
     **/
    func addAnnotation(latitude: Double, longitude: Double) {
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        newAnnotation.title = "Car"
        mapView.addAnnotation(newAnnotation)
    }
    
    /**
     This method is to remove the car location when the new marker is added.
     **/
    private func removeAnnotation() {
        mapView.removeAnnotations(mapView.annotations)
    }
    
    /**
     This method is to fetch the car current location from the 'raspberryPi' collection
     **/
    func getCarLocationFromFirestore() {
        let db = Firestore.firestore()
        // Fetching data from currentValues in the raspberry pi collection
        let carLocationRef = db.collection("raspberryPiData").document("raspberryPi1")
        carLocationRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let currentLocation = document.data()!["currentLocation"] as! [String : Any]
                
                let lat = (currentLocation["latitude"] as! NSString).doubleValue
                let long = (currentLocation["longitude"] as! NSString).doubleValue
                let time = currentLocation["timeStamp"] as! String

                self.updateTimeStamp(timeStamp: time)
                self.addAnnotation(latitude: lat, longitude: long)
                var currentCarLocation = CLLocation()
                currentCarLocation = CLLocation(latitude: lat, longitude: long)

                self.showAddress(currentCarLocation: currentCarLocation)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func updateTimeStamp(timeStamp: String) {
        lastUpdateTime.text = "Last update: \(timeStamp)"
    }
    
    /**
     This method is to display the current car location address through the Placemark.
     **/
    func showAddress(currentCarLocation: CLLocation) {
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
                self.addressLabel.text = "\(streetNumber) \(streetName) \(suburbName) \(cityName)"
            }
        }
    }
}

extension MapScreenViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLatestLocation = locations.first else { return }
        
        if userCurrentLocation == nil {
            zoomToLatestLocation(with: userLatestLocation.coordinate)
        }
        userCurrentLocation = userLatestLocation.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationServiceAuthorization()
    }
}

extension MapScreenViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    
        }
}

