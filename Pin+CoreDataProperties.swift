//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Emmanuoel Eldridge on 7/8/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: NSSet?

}
