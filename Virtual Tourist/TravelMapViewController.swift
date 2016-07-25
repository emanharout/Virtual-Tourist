

import UIKit
import CoreData
import MapKit

class TravelMapViewController: UIViewController {
	
	let stack = CoreDataStack.sharedInstance
	var editMode = false
	var mapPosition: MapPosition!
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var editView: UIView!
	@IBOutlet weak var editLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupMapviewGestureRecognizer()
		fetchPins()
		configureMapPosition()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.setToolbarHidden(true, animated: true)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// Mapview span/altitude values are automatically modified and snaps to other levels until view appears, must set region here
		if !mapPosition.mapPositionWasSet {
			mapPosition.setMapToLastPosition()
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
	
	// MARK: Map-Related Functions
	func addPin() {
		if let gestureRecognizer = mapView.gestureRecognizers?[0] {
			if gestureRecognizer.state == .Began && !editMode {
				let longTapPoint = gestureRecognizer.locationInView(mapView)
				let coordinate = mapView.convertPoint(longTapPoint, toCoordinateFromView: mapView)
				
				let annotation = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: stack.context)
				stack.save()
				
				mapView.addAnnotation(annotation)
			}
		}
	}
	
	func refreshPins(pins: [Pin]) {
		let allAnnotations = mapView.annotations
		mapView.removeAnnotations(allAnnotations)
		mapView.addAnnotations(pins)
	}
	
	func setupMapviewGestureRecognizer() {
		let gestureRec = UILongPressGestureRecognizer(target: self, action: #selector(addPin))
		mapView.addGestureRecognizer(gestureRec)
	}
	
	func configureMapPosition() {
		mapPosition = MapPosition(mapView: mapView, storedMapRegion: nil)
		mapPosition.retrieveMapRegion()
		
		if mapPosition.storedMapRegion != nil && !mapPosition.mapPositionWasSet {
			mapView.centerCoordinate = mapPosition.storedMapRegion!.center
		}
	}
	
	// MARK: Delegate Methods
	func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		mapPosition.storeRegionValues()
	}
	
	func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
		let annotation = view.annotation as! Pin
		if editMode {
			mapView.removeAnnotation(annotation)
			stack.context.deleteObject(annotation)
			stack.save()
		} else {
			mapView.deselectAnnotation(annotation, animated: false)
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
