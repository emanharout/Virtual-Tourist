

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
	@IBOutlet weak var bottomBarButton: UIBarButtonItem!
	
	var pin: Pin!
	var fetchedResultsController: NSFetchedResultsController<Photo>!
	let stack = CoreDataStack.sharedInstance
	var blockOperations: [BlockOperation] = []
	var pageCounter = 1
	var selectedItems: [IndexPath] = [] {
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
		let fetchRequest: NSFetchRequest<Photo>! = NSFetchRequest(entityName: "Photo")
		let sortDescriptor = NSSortDescriptor(key: "url", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
		fetchRequest.predicate = predicate
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
		
		var results = [Photo]()
		do {
			try fetchedResultsController.performFetch()
			results = fetchedResultsController.fetchedObjects!
		} catch {
			print("Error when performing fetch")
		}
		
		return results
	}
	
	func getPhotoURLs() {
		FlickrClient.sharedInstance.getPhotoURLsWithLocation(pin.latitude, longitude: pin.longitude, pageNumber: pageCounter) { (result, pages, error) in
			if let error = error {
				print(error.userInfo["NSUnderlyingErrorKey"])
			} else if let result = result, let pages = pages {
				for i in result {
					let url = String(describing: i)
					print("URL IS \(url)")
					_ = Photo(pin: self.pin, url: url)
				}
				self.pageCounter = (self.pageCounter < pages) ? self.pageCounter + 1 : 1
				self.stack.save()
			}
		}
	}
	
	@IBAction func bottomBarButtonPressed(_ sender: UIBarButtonItem) {
		if selectedItems.isEmpty {
			for photo in fetchedResultsController.fetchedObjects! {
				fetchedResultsController.managedObjectContext.delete(photo)
			}
			getPhotoURLs()
		} else {
			for indexPath in selectedItems {
				let photo = fetchedResultsController.object(at: indexPath)
				fetchedResultsController.managedObjectContext.delete(photo)
			}
			selectedItems.removeAll()
			stack.save()
		}
	}
	
	// MARK: UI-Related Functions
	func makeRegionWithAnnotation(_ annotation: MKAnnotation) -> MKCoordinateRegion {
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
	
	
	func performOnMainThread(_ block: @escaping ()->Void) {
		let mainQueue = DispatchQueue.main
		mainQueue.async(execute: block)
	}
}



extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	// MARK: CollectionView Delegate Functions
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
		cell.activityIndicator.isHidden = true
		let photo = fetchedResultsController.object(at: indexPath)
		
		if let imageData = photo.imageData {
			cell.imageView.image = UIImage(data: imageData)
		} else {
			assignCellNewPhoto(cell, photo: photo)
			stack.save()
		}
		
		setCellAlphaValue(cell, indexPath: indexPath)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let numberOfItems: Int
		guard let fetchedItems = fetchedResultsController.fetchedObjects?.count else {
			numberOfItems = 0
			return numberOfItems
		}
		numberOfItems = fetchedItems
		return numberOfItems
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
		if let index = selectedItems.index(of: indexPath) {
			selectedItems.remove(at: index)
		} else {
			selectedItems.append(indexPath)
		}
		setCellAlphaValue(cell, indexPath: indexPath)
	}
	
	func assignCellNewPhoto(_ cell: PhotoCell, photo: Photo) {
		cell.imageView.image = UIImage(named: "placeholder")
		cell.activityIndicator.startAnimating()
		cell.activityIndicator.isHidden = false
		let url = URL(string: photo.url)!
		
		let task = FlickrClient.sharedInstance.downloadDataWithURL(url) { (data, error) in
			if let error = error {
				print(error.userInfo["NSUnderlyingErrorKey"])
			} else {
				self.performOnMainThread(){
					photo.imageData = data!
					let image = UIImage(data: data!)
					cell.activityIndicator.stopAnimating()
					cell.activityIndicator.isHidden = true
					cell.imageView.image = image
				}
			}
		}
		cell.task = task
	}
	
	func setCellAlphaValue(_ cell: PhotoCell, indexPath: IndexPath) {
		if selectedItems.index(of: indexPath) != nil {
			cell.imageView.alpha = 0.55
		} else {
			cell.imageView.alpha = 1.0
		}
	}
	
}



extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
	// MARK: FetchedResultsController Delegate Methods
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		
		switch type {
		case .insert:
			blockOperations.append(
				BlockOperation(){ [weak self] in
					if let this = self {
						this.collectionView!.insertItems(at: [newIndexPath!])
					}
				}
			)
		case .update:
			blockOperations.append(
				BlockOperation() { [weak self] in
					if let this = self {
						this.collectionView!.reloadItems(at: [indexPath!])
					}
				}
			)
		case .delete:
			blockOperations.append(
				BlockOperation() { [weak self] in
					if let this = self {
						this.collectionView!.deleteItems(at: [indexPath!])
					}
				}
			)
		case .move:
			blockOperations.append(
				BlockOperation() { [weak self] in
					if let this = self {
						this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
					}
				}
			)
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		
		// Source: https://gist.github.com/iwasrobbed/5528897
		let batchUpdatesToPerform = {() -> Void in
			for operation in self.blockOperations {
				operation.start()
			}
		}
		collectionView!.performBatchUpdates(batchUpdatesToPerform) { (finished) -> Void in
			self.blockOperations.removeAll(keepingCapacity: false)
		}
	}
}
