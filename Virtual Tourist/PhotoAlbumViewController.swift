

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
	
	var pin: Pin!
	var photoURLs: [NSURL]?
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
		
		setupFlowLayout()
		
		if fetchPhotos().isEmpty {
			getPhotoURLs()
		} else {
			// Setup UI
			print("fetch was not empty")
		}
	}
	
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
	
	func getPhotoURLs() {
		FlickrClient.sharedInstance.getPhotoURLsWithLocation(pin.latitude, longitude: pin.longitude) { (result, error) in
			if let error = error {
				print(error.userInfo["NSUnderlyingErrorKey"])
			} else if let result = result {
				self.photoURLs = result
				//TODO: Additional Setup
				// ABC TESTing
			}
		}
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
	
	func setupFlowLayout() {
		let itemDimension = ((view.frame.size.width - 10.0)/3)
		flowLayout.minimumLineSpacing = CGFloat(5.0)
		flowLayout.minimumInteritemSpacing = CGFloat(5.0)
		flowLayout.itemSize = CGSize(width: itemDimension, height: itemDimension)
	}
}



extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		
//		        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
//		        let photoData = photo.imageData
//		        let image = UIImage(data: photoData!)
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
		cell.imageView.image = UIImage(named: "placeholder")
		if let url = photoURLs?[indexPath.row] {
			FlickrClient.sharedInstance.downloadDataFromURL(url) { (result, error) in
				guard let data = result else {
					return
				}
				let downloadedImage = UIImage(data: data)
				self.performOnMainThread{
					cell.imageView.image = downloadedImage
				}
			}
		}
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let numberOfItems: Int
		guard let fetchedItems = fetchedResultsController.fetchedObjects?.count else {
			numberOfItems = 0
			return numberOfItems
		}
		numberOfItems = min(fetchedItems, 21)
		return numberOfItems
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
