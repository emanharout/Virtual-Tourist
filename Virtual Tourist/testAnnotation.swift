//
//  testAnnotation.swift
//  Virtual Tourist
//
//  Created by Emmanuoel Eldridge on 7/7/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import UIKit
import MapKit

class testAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
}
