


import CoreData


// MARK:  - Main
struct CoreDataStack {
    
    
    // MARK:  - Properties
    private let model : NSManagedObjectModel
    private let coordinator : NSPersistentStoreCoordinator
    private let modelURL : NSURL
    private let dbURL : NSURL
    private let persistingContext : NSManagedObjectContext
    private let backgroundContext : NSManagedObjectContext
    let context : NSManagedObjectContext
    
    static let sharedInstance = CoreDataStack(modelName: "Model")!
    
    // MARK:  - Initializers
    private init?(modelName: String){
        
        // Assumes the model is in the main bundle
        guard let modelURL = NSBundle.mainBundle().URLForResource(modelName, withExtension: "momd") else {
            print("Unable to find \(modelName)in the main bundle")
            return nil}
        
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else{
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        
        
        // Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Create a persistingContext (private queue) and a child one (main queue)
        // create a context and add connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        persistingContext.name = "Persisting"
        persistingContext.persistentStoreCoordinator = coordinator
        
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = persistingContext
        context.name = "Main"
        
        // Create a background context child of main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        backgroundContext.parentContext = context
        backgroundContext.name = "Background"
        
        
        // Add a SQLite store located in the documents folder
        let fm = NSFileManager.defaultManager()
        
        guard let  docUrl = fm.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else{
            print("Unable to reach the documents folder")
            return nil
        }
        
        self.dbURL = docUrl.URLByAppendingPathComponent("model.sqlite")!
		
		let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption : true]
        
        do{
            try addStoreTo(coordinator: coordinator,
                           storeType: NSSQLiteStoreType,
                           configuration: nil,
                           storeURL: dbURL,
                           options: options)
            
        }catch{
            print("unable to add store at \(dbURL)")
        }
        
    }
    
    // MARK:  - Utils
    func addStoreTo(coordinator coord : NSPersistentStoreCoordinator,
                                storeType: String,
                                configuration: String?,
                                storeURL: NSURL,
                                options : [NSObject : AnyObject]?) throws{
        
        try coord.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: nil)
    }
}



extension CoreDataStack {
    
    func save() {
		let mainQueue = dispatch_get_main_queue()
		dispatch_async(mainQueue) {
			self.context.performBlockAndWait(){
				if self.context.hasChanges{
					do{
						try self.context.save()
					}catch{
						fatalError("Error while saving main context: \(error)")
					}
			
				self.persistingContext.performBlock(){
					do{
						try self.persistingContext.save()
					}catch{
						fatalError("Error while saving persisting context: \(error)")
					}
				}
				}
			}
		}
	}
}

