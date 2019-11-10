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
        var points: [Location]
        points = trip!.locations!
        
        // sort the point based on the point title.
        points = points.sorted(by: { ($0.title!) < ($1.title!) })
        let sorted = points.sorted { (pointOne: Location, pointTwo: Location) -> Bool in
            return (Int(pointOne.title!)!) < (Int(pointTwo.title!)!)
        }
        
        // append the coordinate to a new list based on the new order.
        for i in sorted {
            lists.append(i.coordinate)
            print(i.title!)
        }
        
        // add the start point and the end point.
        guard lists.count > 0 else { return }
        addAnnotation(sourceLocation: lists[0], destinationLocation: lists[lists.count - 1])

        // skip the 10 point when drawing the routes.
        var i = 0
        while i < lists.count {
            if i + 10 >= lists.count {
                drawLines(sourceLocation: lists[i], destinationLocation: lists[lists.count - 1])
                break
            }
            drawLines(sourceLocation: lists[i], destinationLocation: lists[i + 10])
            i = i + 10
        }
    }
    
    /**
     This method is to set the start point and end point.
     **/
    func addAnnotation(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) {
        let sourcePin = Location(title: "Start Point", subTitle: "Source", coordinate: sourceLocation)
        let destinationPin = Location(title: "End Point", subTitle: "Destination", coordinate: destinationLocation)
        
        self.mapView.addAnnotation(sourcePin)
        self.mapView.addAnnotation(destinationPin)
    }

    /**
     This method is to draw the route between points.
     **/
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

