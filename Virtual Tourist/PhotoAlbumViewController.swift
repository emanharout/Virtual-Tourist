

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
	@IBOutlet weak var bottomBarButton: UIBarButtonItem!
	
	var pin: Pin!
	var fetchedResultsController: NSFetchedResultsController!
	let stack = CoreDataStack.sharedInstance
	var blockOperations: [NSBlockOperation] = []
	var pageCounter = 1
	var selectedItems: [NSIndexPath] = [] {
		didSet {
			bottomBarButton.title = selectedItems.isEmpty ? "New Collection" : "Delete Images"
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupMapView()
		setupFlowLayout()
		
		navigationController?.setToolbarHidden(false, animated: true)
		
		if fetchPhotos().isEmpty {
			getPhotoURLs()
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
		FlickrClient.sharedInstance.getPhotoURLsWithLocation(pin.latitude, longitude: pin.longitude, pageNumber: pageCounter) { (result, pages, error) in
			if let error = error {
				print(error.userInfo["NSUnderlyingErrorKey"])
			} else if let result = result, pages = pages {
				self.performOnMainThread(){
					for i in result {
						let url = String(i)
						_ = Photo(pin: self.pin, url: url)
					}
					self.pageCounter = (self.pageCounter < pages) ? self.pageCounter + 1 : 1
					self.stack.save()
					print("page counter number: \(self.pageCounter)")
				}
			}
		}
	}
	
	@IBAction func bottomBarButtonPressed(sender: UIBarButtonItem) {
		if selectedItems.isEmpty {
			for photo in fetchedResultsController.fetchedObjects as! [Photo] {
				fetchedResultsController.managedObjectContext.deleteObject(photo)
			}
			getPhotoURLs()
		} else {
			for indexPath in selectedItems {
				guard let photo = fetchedResultsController.objectAtIndexPath(indexPath) as? Photo else {
					continue
				}
				fetchedResultsController.managedObjectContext.deleteObject(photo)
			}
			selectedItems.removeAll()
			stack.save()
		}
	}
	
	// MARK: UI-Related Functions
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
	
	func setupMapView() {
		mapView.addAnnotation(pin)
		mapView.region = makeRegionWithAnnotation(pin)
	}
	
	
	func performOnMainThread(block: ()->Void) {
		let mainQueue = dispatch_get_main_queue()
		dispatch_async(mainQueue, block)
	}
}



extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	// MARK: CollectionView Delegate Functions
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
		cell.activityIndicator.hidden = true
		let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
		
		if let imageData = photo.imageData {
			cell.imageView.image = UIImage(data: imageData)
		} else {
			assignCellNewPhoto(cell, photo: photo)
		}

		setCellAlphaValue(cell, indexPath: indexPath)
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let numberOfItems: Int
		guard let fetchedItems = fetchedResultsController.fetchedObjects?.count else {
			numberOfItems = 0
			return numberOfItems
		}
		numberOfItems = fetchedItems
		return numberOfItems
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
		if let index = selectedItems.indexOf(indexPath) {
			selectedItems.removeAtIndex(index)
		} else {
			selectedItems.append(indexPath)
		}
		setCellAlphaValue(cell, indexPath: indexPath)
	}
	
	func assignCellNewPhoto(cell: PhotoCell, photo: Photo) {
		cell.imageView.image = UIImage(named: "placeholder")
		cell.activityIndicator.startAnimating()
		cell.activityIndicator.hidden = false
		let url = NSURL(string: photo.url)
		
		FlickrClient.sharedInstance.downloadDataFromURL(url!) { (result, error) in
			if let error = error {
				print(error.userInfo["NSUnderlyingErrorKey"])
			} else {
				self.performOnMainThread(){
					photo.imageData = result!
					let image = UIImage(data: result!)
					cell.activityIndicator.stopAnimating()
					cell.activityIndicator.hidden = true
					cell.imageView.image = image
				}
			}
		}
	}
	
	func setCellAlphaValue(cell: PhotoCell, indexPath: NSIndexPath) {
		if selectedItems.indexOf(indexPath) != nil {
			cell.imageView.alpha = 0.55
		} else {
			cell.imageView.alpha = 1.0
		}
	}

}



extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
	// MARK: FetchedResultsController Delegate Methods
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
	}

	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		
		switch type {
		case .Insert:
			blockOperations.append(
				NSBlockOperation(){ [weak self] in
					if let this = self {
						this.collectionView!.insertItemsAtIndexPaths([newIndexPath!])
					}
				}
			)
		case .Update:
			blockOperations.append(
				NSBlockOperation() { [weak self] in
					if let this = self {
						this.collectionView!.reloadItemsAtIndexPaths([indexPath!])
					}
				}
			)
		case .Delete:
			blockOperations.append(
				NSBlockOperation() { [weak self] in
					if let this = self {
						this.collectionView!.deleteItemsAtIndexPaths([indexPath!])
					}
				}
			)
		case .Move:
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
		
		// Source: https://gist.github.com/iwasrobbed/5528897
		let batchUpdatesToPerform = {() -> Void in
			for operation in self.blockOperations {
				operation.start()
			}
		}
		collectionView!.performBatchUpdates(batchUpdatesToPerform) { (finished) -> Void in
			self.blockOperations.removeAll(keepCapacity: false)
		}
	}
}
