//
//  TripViewController.swift
//  FIT5140_FinalAssignment
//
//  Created by Yujie Wu on 2/11/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import MapKit

class TripViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!

    var trip: Trip?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var lists = [CLLocationCoordinate2D]()
        
        for i in trip!.locations! {
            lists.append(i.coordinate)
        }
        
        guard lists.count > 0 else { return }
        
        addAnnotation(sourceLocation: lists[0], destinationLocation: lists[lists.count - 1])
        
        for i in 0..<lists.count {
            if i + 1 < lists.count {
                drawLines(sourceLocation: lists[i], destinationLocation: lists[i + 1])
            } else {
                break
            }
        }
    }
    
    func addAnnotation(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) {
        let sourcePin = Location(title: "Start Point", subTitle: "Source", coordinate: sourceLocation)
        let destinationPin = Location(title: "End Point", subTitle: "Destination", coordinate: destinationLocation)
        
        self.mapView.addAnnotation(sourcePin)
        self.mapView.addAnnotation(destinationPin)
    }

    func drawLines(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D){
        

        // Draw line
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)

        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile

        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {
                if let error = error {
                    print("dreiction error: \(error.localizedDescription)")
                }
                return
            }

            let route = directionResponse.routes[0] //choose the fast route
            print(route)
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            //self.mapView.addOverlays(route.polyline, level: .aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }

        self.mapView.delegate = self
    }

    // MARK:- Mapkit delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        return renderer
    }

}

