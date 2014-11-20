//
//  SRCoreDataTestCase.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/18/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import XCTest
import CoreData

class SRCoreDataTestCase: XCTestCase {

    lazy var managedObjectModel: NSManagedObjectModel = {
        return  NSManagedObjectModel.mergedModelFromBundles(nil)!;
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil);
        var tempStoreCordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!);
        let options: [String: Bool] = [
            NSMigratePersistentStoresAutomaticallyOption : true,
            NSInferMappingModelAutomaticallyOption : true
        ];
            
        let tempURLS = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask);
        
        let storeURL = (tempURLS[tempURLS.count - 1]).URLByAppendingPathComponent(kStorePathComponent);
        
        var error: NSError?;
        tempStoreCordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error);
    
        if error != nil {
            NSLog("\(error)");
        }
        
        return tempStoreCordinator;
    }();
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        var tempMain = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType);
        tempMain.persistentStoreCoordinator = self.persistentStoreCoordinator;
        
        return tempMain;
    }();
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        managedObjectContext = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

}
