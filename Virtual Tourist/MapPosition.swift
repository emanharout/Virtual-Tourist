//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit
import MapKit

class MapPosition: NSObject {
	
	var mapView: MKMapView
	var storedMapRegion: MKCoordinateRegion?
	var mapPositionWasSet = false
	
	func retrieveMapRegion() {
		if let latitude = UserDefaults.standard.value(forKey: "centerCoordinateLatitude") as? CLLocationDegrees,
			let longitude = UserDefaults.standard.value(forKey: "centerCoordinateLongitude") as? CLLocationDegrees,
			let spanLat = UserDefaults.standard.value(forKey: "spanLat") as? CLLocationDegrees,
			let spanLong = UserDefaults.standard.value(forKey: "spanLong") as? CLLocationDegrees {
			
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
	
	func storeRegionValues() {
		let region = mapView.region
		let latitude = region.center.latitude
		let longitude = region.center.longitude
		let spanLat = region.span.latitudeDelta
		let spanLong = region.span.longitudeDelta
		
		UserDefaults.standard.set(latitude, forKey: "centerCoordinateLatitude")
		UserDefaults.standard.set(longitude, forKey: "centerCoordinateLongitude")
		UserDefaults.standard.set(spanLat, forKey: "spanLat")
		UserDefaults.standard.set(spanLong, forKey: "spanLong")
		UserDefaults.standard.synchronize()
	}
	
	
	init(mapView: MKMapView, storedMapRegion: MKCoordinateRegion?) {
		self.mapView = mapView
		self.storedMapRegion = nil
		
		super.init()
	}
}
