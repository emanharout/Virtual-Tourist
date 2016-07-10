//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Emmanuoel Eldridge on 7/6/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class TravelMapViewController: UIViewController {
    
    let stack = CoreDataStack.sharedInstance
    
    
    @IBOutlet weak var travelMapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        travelMapView.delegate = self
        let gestureRec = UILongPressGestureRecognizer(target: self, action: #selector(addPin))
        travelMapView.addGestureRecognizer(gestureRec)
        
        
    }
    
    
    

}


extension TravelMapViewController: MKMapViewDelegate {
    
    func addPin() {
        if let gestureRecognizer = travelMapView.gestureRecognizers?[0] {
            if gestureRecognizer.state == .Began {
                let longTapPoint = gestureRecognizer.locationInView(travelMapView)
                let coordinate = travelMapView.convertPoint(longTapPoint, toCoordinateFromView: travelMapView)
                

                let annotation = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: stack.context)
                annotation.latitude = coordinate.latitude
                annotation.longitude = coordinate.longitude
                
                travelMapView.addAnnotation(annotation)
                
                setRegionToAnnotation(annotation)
            }
        }
    }
    
    func setRegionToAnnotation(annotation: MKAnnotation) {
        let center = annotation.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: center, span: span)
        travelMapView.setRegion(region, animated: true)

    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let coordinate = view.annotation?.coordinate {
            print("pass mapView Region")
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotView = mapView.dequeueReusableAnnotationViewWithIdentifier("pinView") as? MKPinAnnotationView
        
        if annotView == nil {
            annotView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            return annotView
        }
        annotView?.annotation = annotation
        return annotView
    }
    
}

