//
//  SRCoreDataContextProvider.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/18/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import CoreData

class SRCoreDataContextProvider: NSObject {
    
    class var sharedInstance: SRCoreDataContextProvider {
        struct Static {
            static let instance: SRCoreDataContextProvider = SRCoreDataContextProvider();
        }
        return Static.instance;
    }
    
    private var storePath: String = kStorePathComponent;
    
    private lazy var mainObjectContext: NSManagedObjectContext = {
        var tempMain = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType);
        tempMain.persistentStoreCoordinator = self.storeCoordinator;
        
        return tempMain;
    }();
    
    private lazy var storeCoordinator: NSPersistentStoreCoordinator = {
        
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil);
        var tempStoreCordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!);
        
        var error: NSError?;
        
        //for migration
        let options: [String: Bool] = [
            NSMigratePersistentStoresAutomaticallyOption : true,
            NSInferMappingModelAutomaticallyOption : true
        ];
        
        let tempURLS = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask);
        
        let storeURL = (tempURLS[tempURLS.count - 1]).URLByAppendingPathComponent(self.storePath);
        
        tempStoreCordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error);
        
        if error != nil {
            NSLog("\(error)");
        }
        
        return tempStoreCordinator;
    }();
    
    override init() {
        
    }
    
    class func mainManagedObjectContext() -> NSManagedObjectContext {

        assert(NSThread.isMainThread(), "You should call this method only from main thread!!!")
        return self.sharedInstance.mainObjectContext;
    }
    
    class func workingManagedObjectContext()-> NSManagedObjectContext {
        
        var newWorkingContext: NSManagedObjectContext = NSManagedObjectContext();
        newWorkingContext.persistentStoreCoordinator = self.sharedInstance.storeCoordinator;
        newWorkingContext.undoManager = nil;
        
        return newWorkingContext;
    }
    
    class func saveWorkingContext(workingContext: NSManagedObjectContext) -> Bool {
        
        var result = false;
        
        if (workingContext.hasChanges) {
            
            NSNotificationCenter.defaultCenter().addObserver(self.sharedInstance, selector: "workingContextDidSave:", name: NSManagedObjectContextDidSaveNotification, object: workingContext);
            
            var error: NSError? = nil;
            workingContext.save(&error);

            result = error == nil;
            
            NSNotificationCenter.defaultCenter().removeObserver(self.sharedInstance, name: NSManagedObjectContextDidSaveNotification, object: workingContext)
        }
        
        return result;
    }
    
    func workingContextDidSave(notification: NSNotification) {
     
        dispatch_async(dispatch_get_main_queue(), { [weak self]() -> Void in
            
            if let strongSelf = self {
                
                strongSelf.mergeChangesFromContextDidSaveNotification(notification);
            }
        });
    }
    
    func mergeChangesFromContextDidSaveNotification(notification: NSNotification) {
        
        self.mainObjectContext.mergeChangesFromContextDidSaveNotification(notification);
    }
}