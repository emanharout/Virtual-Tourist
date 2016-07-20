

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    var pin: Pin!
    var fetchedResultsController: NSFetchedResultsController!
    let stack = CoreDataStack.sharedInstance
    var insertedItemsIndex: [NSIndexPath]!
    var deletedItemsIndex: [NSIndexPath]!
    

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.addAnnotation(pin)
        mapView.region = makeRegionWithAnnotation(pin)
        
        let itemWidth = ((view.frame.size.width - 15.0)/3)
        flowLayout.minimumLineSpacing = CGFloat(5.0)
        flowLayout.minimumInteritemSpacing = CGFloat(5.0)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if fetchPhotos().isEmpty {
            FlickrClient.sharedInstance.getPhotoURLsWithLocation(pin.latitude, longitude: pin.longitude) { (result, error) in
               if let error = error {
                    print(error.userInfo["NSUnderlyingErrorKey"])
                } else if let result = result {
                    //TODO: Additional Setup
                }
            }
        } else {
            // Setup UI
            print("fetch was not empty")
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
            print("RESULTS: \(results)")
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



extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
//        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
//        let photoData = photo.imageData
//        let image = UIImage(data: photoData!)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        cell.imageView.image = UIImage(named: "placeholder")
//
//        cell.imageView.image = image
//        collectionView.reloadData()
//        
//        return cell
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collect view number items")
        return 21
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}



extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        insertedItemsIndex = [NSIndexPath]()
//        deletedItemsIndex = [NSIndexPath]()
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        
//        switch type {
//        case .Insert:
//            insertedItemsIndex.append(newIndexPath!)
//        case .Delete:
//            deletedItemsIndex.append(indexPath!)
//        default:
//            break
//        }
//    }
//    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        collectionView.insertItemsAtIndexPaths(insertedItemsIndex)
//        collectionView.deleteItemsAtIndexPaths(deletedItemsIndex)
//    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
