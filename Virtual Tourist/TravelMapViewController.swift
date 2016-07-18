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
    var storedMapRegion: MKCoordinateRegion?
    var mapPositionWasSet = false
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupMapviewGestureRecognizer()
        fetchPins()
        retrieveMapRegion()
        
        //Set center before view appears since its value is not modified automatically by system
        if storedMapRegion != nil && !mapPositionWasSet {
            mapView.centerCoordinate = storedMapRegion!.center
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Mapview span/altitude is automatically modified and snaps to other levels until view appears, must set region here
        if !mapPositionWasSet {
            setMapToLastPosition()
        }
    }
    
    @IBAction func editPressed(sender: UIBarButtonItem) {
        toggleEditMode(sender)
    }
    
    func toggleEditMode(button: UIBarButtonItem) {
        editMode = !editMode
        if editMode {
            UIView.animateWithDuration(0.25){
                self.editView.hidden = false
                self.editLabel.alpha = 1.0
            }
            button.title = "Done"
        } else {
            UIView.animateWithDuration(0.25){
                self.editView.hidden = true
                self.editLabel.alpha = 0.0
            }
            button.title = "Edit"
        }
    }
    
    func setupMapviewGestureRecognizer() {
        let gestureRec = UILongPressGestureRecognizer(target: self, action: #selector(addPin))
        mapView.addGestureRecognizer(gestureRec)
    }
    
    func fetchPins() {
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        var pins: [Pin]
        do {
            let result = try stack.context.executeFetchRequest(fetchRequest) as? [Pin]
            if let result = result {
                pins = result
                refreshPins(pins)
            }
        } catch {
            print("Failed to fetch Pin objects")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPinPhotos" {
            let pin = sender as! Pin
            let destinationVC = segue.destinationViewController as! PhotoAlbumViewController
            destinationVC.pin = pin
        }
    }
}



extension TravelMapViewController: MKMapViewDelegate {
    
    func addPin() {
        if let gestureRecognizer = mapView.gestureRecognizers?[0] {
            if gestureRecognizer.state == .Began && !editMode {
                let longTapPoint = gestureRecognizer.locationInView(mapView)
                let coordinate = mapView.convertPoint(longTapPoint, toCoordinateFromView: mapView)
                
                let annotation = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: stack.context)
                
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    func refreshPins(pins: [Pin]) {
        let allAnnotations = mapView.annotations
        mapView.removeAnnotations(allAnnotations)
        mapView.addAnnotations(pins)
    }
    
    func retrieveMapRegion() {
        if let latitude = NSUserDefaults.standardUserDefaults().valueForKey("centerCoordinateLatitude") as? CLLocationDegrees,
            longitude = NSUserDefaults.standardUserDefaults().valueForKey("centerCoordinateLongitude") as? CLLocationDegrees,
            spanLat = NSUserDefaults.standardUserDefaults().valueForKey("spanLat") as? CLLocationDegrees,
            spanLong = NSUserDefaults.standardUserDefaults().valueForKey("spanLong") as? CLLocationDegrees {
            
            let center = CLLocationCoordinate2DMake(latitude, longitude)
            let span = MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLong)
            storedMapRegion = MKCoordinateRegion(center: center, span: span)
        } else {
            print("Could not set map to last map region")
        }
        
    }
    
    func setMapToLastPosition() {
        if let storedMapRegion = storedMapRegion {
            mapView.region = storedMapRegion
            mapPositionWasSet = true
        }
    }
    
    // MARK: Delegate Methods
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let region = mapView.region
        let latitude = region.center.latitude
        let longitude = region.center.longitude
        let spanLat = region.span.latitudeDelta
        let spanLong = region.span.longitudeDelta
        
        NSUserDefaults.standardUserDefaults().setDouble(latitude, forKey: "centerCoordinateLatitude")
        NSUserDefaults.standardUserDefaults().setDouble(longitude, forKey: "centerCoordinateLongitude")
        NSUserDefaults.standardUserDefaults().setDouble(spanLat, forKey: "spanLat")
        NSUserDefaults.standardUserDefaults().setDouble(spanLong, forKey: "spanLong")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let annotation = view.annotation as! Pin
        if editMode {
            mapView.removeAnnotation(annotation)
            stack.context.deleteObject(annotation)
            stack.save()
        } else {
            performSegueWithIdentifier("showPinPhotos", sender: annotation)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotView = mapView.dequeueReusableAnnotationViewWithIdentifier("pinView") as? MKPinAnnotationView
        
        if annotView == nil {
            annotView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            annotView?.animatesDrop = true
            return annotView
        }
        annotView?.annotation = annotation
        annotView?.animatesDrop = true
        return annotView
    }
}




































