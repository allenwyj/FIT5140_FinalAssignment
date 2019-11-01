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

class MapScreenViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLocationService()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let zoomRegion = MKCoordinateRegion.init(center: center, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationServiceAuthorization()
        
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            checkLocationServiceAuthorization()
            
        } else {
            // notify to turn on
            displayMessage("Please turn on the location service in the Settings.", "Error")
        }
    }
    
    func checkLocationServiceAuthorization() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            focusOnUserLocation()
        } else if CLLocationManager.authorizationStatus() == .denied {
            displayMessage("Please allow to use the location service.", "Error")
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // restricted
            displayMessage("Please turn on the location service in the Settings.", "Error")
        }
    }
    
    func focusOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let zoomRegion = MKCoordinateRegion.init(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            
            mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        }
    }
    
    func displayMessage(_ message: String, _ title: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Get the center location, should be replaced to the location from the firebase
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let lat = mapView.centerCoordinate.latitude
        let long = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: lat, longitude: long)
    }
}

extension MapScreenViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
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
                self.addressLabel.text = "\(streetNumber), \(streetName) \(suburbName) \(cityName)"
            }
        }
    }
}
