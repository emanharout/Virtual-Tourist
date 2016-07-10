//
//  Photo+CoreDataProperties.swift
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

extension Photo {

    @NSManaged var imageData: NSData?
    @NSManaged var pin: Pin?

}
