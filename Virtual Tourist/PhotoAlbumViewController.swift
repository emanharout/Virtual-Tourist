//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Emmanuoel Eldridge on 7/14/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var pin: Pin!
    var fetchedResultsController: NSFetchedResultsController!
    let stack = CoreDataStack.sharedInstance
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.addAnnotation(pin)
        mapView.region = makeRegionWithAnnotation(pin)
        
        if fetchPhotos().isEmpty {
            FlickrClient.sharedInstance.retrieveImageData(pin) { (result, error) in
                if let error = error {
                    print(error.userInfo["NSUnderlyingErrorKey"])
                } else if let result = result {
                    self.performOnMainThread{
                        for imageData in result {
                            Photo(data: imageData, pin: self.pin)
                        }
                        self.stack.save()
                    }
                }
            }
        } else {
            // Setup UI
        }
    }

    
    
    // TODO: Check if lack of sort desc causes issue w/ results
    func fetchPhotos() -> [Photo] {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor]()
        let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
        fetchRequest.predicate = predicate
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        var results = [Photo]()
        do {
            try fetchedResultsController.performFetch()
            results = fetchedResultsController.fetchedObjects as! [Photo]
        } catch {
            print("Error when performing fetch")
        }
        return results
    }
    
    func performOnMainThread(block: ()->Void) {
        let mainQueue = dispatch_get_main_queue()
        dispatch_async(mainQueue, block)
    }
    
    func makeRegionWithAnnotation(annotation: MKAnnotation) -> MKCoordinateRegion {
        let center = annotation.coordinate
        let span = MKCoordinateSpanMake(0.002, 0.002)
        let region = MKCoordinateRegion(center: center, span: span)
        return region
    }
    
}
