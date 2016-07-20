//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit
import MapKit

class MapPosition: NSObject {

    var mapView: MKMapView
    var storedMapRegion: MKCoordinateRegion?
    var mapPositionWasSet = false
    
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
    
    func storeRegionValues() {
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
    
    
    init(mapView: MKMapView, storedMapRegion: MKCoordinateRegion?) {
        self.mapView = mapView
        self.storedMapRegion = nil
        
        super.init()
    }
}
