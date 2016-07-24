
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

	convenience init(pin: Pin, url: String) {
        if let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: CoreDataStack.sharedInstance.context) {
            self.init(entity: entity, insertIntoManagedObjectContext: CoreDataStack.sharedInstance.context)
            self.pin = pin
            self.url = url
        } else {
            fatalError("Failed to initialize Photo")
        }
    }

}
