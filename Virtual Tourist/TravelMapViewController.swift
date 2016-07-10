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
        
        setMapToLastPosition()
    }

}



extension TravelMapViewController: MKMapViewDelegate {
    
    func addPin() {
        if let gestureRecognizer = travelMapView.gestureRecognizers?[0] {
            if gestureRecognizer.state == .Began {
                let longTapPoint = gestureRecognizer.locationInView(travelMapView)
                let coordinate = travelMapView.convertPoint(longTapPoint, toCoordinateFromView: travelMapView)
                
                let annotation = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: stack.context)
                
                travelMapView.addAnnotation(annotation)
                let region = makeRegionWithAnnotation(annotation)
                travelMapView.setRegion(region, animated: true)
            }
        }
    }
    
    func makeRegionWithAnnotation(annotation: MKAnnotation) -> MKCoordinateRegion {
        let center = annotation.coordinate
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: center, span: span)
        return region
    }
    
    func setMapToLastPosition() {
        if let latitude = NSUserDefaults.standardUserDefaults().valueForKey("centerCoordinateLatitude") as? CLLocationDegrees,
            longitude = NSUserDefaults.standardUserDefaults().valueForKey("centerCoordinateLongitude") as? CLLocationDegrees,
            altitude = NSUserDefaults.standardUserDefaults().valueForKey("mapViewAltitude") as? CLLocationDistance {
            
            travelMapView.centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
            travelMapView.camera.altitude = altitude
            
        } else {
            print("Could not set map to last map region")
        }
    }
    
    
    // MARK: Delegate Methods
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let annotation = view.annotation {
            annotation.coordinate
            
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
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let region = mapView.region
        let latitude = region.center.latitude
        let longitude = region.center.longitude
        let altitude = mapView.camera.altitude
        
        NSUserDefaults.standardUserDefaults().setDouble(latitude, forKey: "centerCoordinateLatitude")
        NSUserDefaults.standardUserDefaults().setDouble(longitude, forKey: "centerCoordinateLongitude")
        NSUserDefaults.standardUserDefaults().setDouble(altitude, forKey: "mapViewAltitude")
        
    }
}




































