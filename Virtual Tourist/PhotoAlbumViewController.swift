

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
	
	var pin: Pin!
	var fetchedResultsController: NSFetchedResultsController!
	let stack = CoreDataStack.sharedInstance
	var blockOperations: [NSBlockOperation] = []
	var insertedItemIndex: [NSIndexPath]!
	var deletedItemIndex: [NSIndexPath]!
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
	@IBOutlet weak var bottomBarButton: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.addAnnotation(pin)
		mapView.region = makeRegionWithAnnotation(pin)
		
		setupFlowLayout()
		navigationController?.setToolbarHidden(false, animated: true)
		
		if fetchPhotos().isEmpty {
			getPhotoURLs()
		} else {
			// Setup UI
			print("fetch was not empty")
		}
	}
	
	func fetchPhotos() -> [Photo] {
		let fetchRequest = NSFetchRequest(entityName: "Photo")
		fetchRequest.fetchLimit = 21
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
	
	func getPhotoURLs() {
		FlickrClient.sharedInstance.getPhotoURLsWithLocation(pin.latitude, longitude: pin.longitude) { (result, error) in
			if let error = error {
				print(error.userInfo["NSUnderlyingErrorKey"])
			} else if let result = result {
				print("Gonna Create Photos")
				self.performOnMainThread(){
					for i in result {
						let url = String(i)
						_ = Photo(pin: self.pin, url: url)
					}
					self.collectionView.reloadData()
					print("Reload CollectionView")
				}
			}
		}
	}
	
	func performOnMainThread(block: ()->Void) {
		let mainQueue = dispatch_get_main_queue()
		dispatch_async(mainQueue, block)
	}
	
	@IBAction func bottomBarButtonPressed(sender: UIBarButtonItem) {
		
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
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
		
		let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
		if let imageData = photo.imageData {
			cell.imageView.image = UIImage(data: imageData)
			print("Existing Image Assigned")
		} else {
			
			cell.imageView.image = UIImage(named: "placeholder")
			let url = NSURL(string: photo.url)
			
			FlickrClient.sharedInstance.downloadDataFromURL(url!) { (result, error) in
				if let error = error {
					print(error.userInfo["NSUnderlyingErrorKey"])
				} else {
					photo.imageData = result!
					let image = UIImage(data: result!)
					
					self.performOnMainThread(){
						cell.imageView.image = image
					}
				}
			}
			print("New Image Downloaded and Assigned")
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
		return fetchedItems
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		
	}
	
	func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
		
	}
	
}



extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		print("Will make change")
		
	}

	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		
		switch type {
		case .Insert:
			print("Insert Object Index: \(newIndexPath?.row)")
			
			blockOperations.append(
				NSBlockOperation(){ [weak self] in
					if let this = self {
						this.collectionView!.insertItemsAtIndexPaths([newIndexPath!])
					}
				}
			)
				
		case .Update:
			print("Update Object Index: \(indexPath?.row)")
			blockOperations.append(
				NSBlockOperation() { [weak self] in
					if let this = self {
						this.collectionView!.reloadItemsAtIndexPaths([indexPath!])
					}
				}
			)
		case .Delete:
			print("Delete Object Index: \(indexPath?.row)")
			blockOperations.append(
				NSBlockOperation() { [weak self] in
					if let this = self {
						this.collectionView!.deleteItemsAtIndexPaths([indexPath!])
					}
				}
			)
		case .Move:
			print("Move Object Index: \(indexPath?.row) to New Index: \(newIndexPath?.row)")
			blockOperations.append(
				NSBlockOperation() { [weak self] in
					if let this = self {
						this.collectionView!.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
					}
				}
			)
		}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
	
//			collectionView.reloadItemsAtIndexPaths(insertedItemIndex)
//			collectionView.deleteItemsAtIndexPaths(deletedItemIndex)
	
//		    collectionView.reloadData()
		
		collectionView!.performBatchUpdates({ () -> Void in
			for operation: NSBlockOperation in self.blockOperations {
				operation.start()
			}
		}, completion: { (finished) -> Void in
				self.blockOperations.removeAll(keepCapacity: false)
		})
		print("FC did finish making changes")
	}

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
