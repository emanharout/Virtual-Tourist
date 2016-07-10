//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Emmanuoel Eldridge on 7/8/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import Foundation
import MapKit
import CoreData


class Pin: NSManagedObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: entity, insertIntoManagedObjectContext: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Could not initialize Pin")
        }
    }
}