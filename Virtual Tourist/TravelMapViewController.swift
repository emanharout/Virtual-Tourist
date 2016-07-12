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
    var editMode = false
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        let gestureRec = UILongPressGestureRecognizer(target: self, action: #selector(addPin))
        mapView.addGestureRecognizer(gestureRec)
        
        setMapToLastPosition()
    }
    
    override func viewWillAppear(animated: Bool) {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        var pins: [Pin]
        do {
            let result = try stack.context.executeFetchRequest(fetchRequest) as? [Pin]
            if let result = result {
                pins = result
                print("PINS ARRAY: \(pins)")
                mapView.addAnnotations(pins)
                print("Annotations Added")
            }
        } catch {
            print("Failed to fetch Pin objects")
        }
    }
    
    @IBAction func editPressed(sender: UIBarButtonItem) {
        editMode = !editMode
        if editMode {
            sender.title = "Done"
        } else {
            sender.title = "Edit"
        }
        
    }
    
    
}



extension TravelMapViewController: MKMapViewDelegate {
    
    func addPin() {
        if let gestureRecognizer = mapView.gestureRecognizers?[0] {
            if gestureRecognizer.state == .Began {
                let longTapPoint = gestureRecognizer.locationInView(mapView)
                let coordinate = mapView.convertPoint(longTapPoint, toCoordinateFromView: mapView)
                
                let annotation = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: stack.context)
                
                mapView.addAnnotation(annotation)
//                let region = makeRegionWithAnnotation(annotation)
//                mapView.setRegion(region, animated: true)

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
            
            mapView.centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude)
            mapView.camera.altitude = altitude
            
        } else {
            print("Could not set map to last map region")
        }
    }
    
    
    // MARK: Delegate Methods
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let annotation = view.annotation as! Pin
        if editMode {
            mapView.removeAnnotation(annotation)
            stack.context.deleteObject(annotation)
            stack.save()
        } else {
            // Segue and pass mapView Region
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




































