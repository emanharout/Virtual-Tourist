

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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.setToolbarHidden(true, animated: true)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Mapview span/altitude values are automatically modified by system and snaps to other levels until view appears, must set region here in order to have final values untampered
		if !mapPosition.mapPositionWasSet {
			mapPosition.setMapToLastPosition()
		}
	}
	
	@IBAction func editPressed(_ sender: UIBarButtonItem) {
		toggleEditMode(sender)
	}
	
	func toggleEditMode(_ button: UIBarButtonItem) {
		editMode = !editMode
		if editMode {
			UIView.animate(withDuration: 0.25, animations: {
				self.editView.isHidden = false
				self.editLabel.alpha = 1.0
			})
			button.title = "Done"
		} else {
			UIView.animate(withDuration: 0.25, animations: {
				self.editView.isHidden = true
				self.editLabel.alpha = 0.0
			})
			button.title = "Edit"
		}
	}
	
	func fetchPins() {
		let fetchRequest: NSFetchRequest<Pin> = NSFetchRequest(entityName: "Pin")
		var pins: [Pin]
		do {
			let result = try stack.context.fetch(fetchRequest)
			pins = result
			refreshPins(pins)
		} catch {
			print("Failed to fetch Pin objects")
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showPinPhotos" {
			let pin = sender as! Pin
			let destinationVC = segue.destination as! PhotoAlbumViewController
			destinationVC.pin = pin
		}
	}
}

extension TravelMapViewController: MKMapViewDelegate {
	
	// MARK: Map-Related Functions
	func addPin() {
		if let gestureRecognizer = mapView.gestureRecognizers?[0] {
			if gestureRecognizer.state == .began && !editMode {
				let longTapPoint = gestureRecognizer.location(in: mapView)
				let coordinate = mapView.convert(longTapPoint, toCoordinateFrom: mapView)
				
				let annotation = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: stack.context)
				stack.save()
				
				mapView.addAnnotation(annotation)
			}
		}
	}
	
	func refreshPins(_ pins: [Pin]) {
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
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		mapPosition.storeRegionValues()
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		let annotation = view.annotation as! Pin
		if editMode {
			mapView.removeAnnotation(annotation)
			stack.context.delete(annotation)
			stack.save()
		} else {
			mapView.deselectAnnotation(annotation, animated: false)
			performSegue(withIdentifier: "showPinPhotos", sender: annotation)
		}
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		
		var annotView = mapView.dequeueReusableAnnotationView(withIdentifier: "pinView") as? MKPinAnnotationView
		
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
