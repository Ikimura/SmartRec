//
//  SRCoreDataManager.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/13/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import CoreData

public class SRCoreDataManager: NSObject {
    
    public class var sharedInstance : SRCoreDataManager {
        struct Static {
            static let instance : SRCoreDataManager = SRCoreDataManager();
        }
        return Static.instance;
    }
    
    internal lazy var masterObjectContext: NSManagedObjectContext = {
        var tempMaster = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType);
        tempMaster.persistentStoreCoordinator = self.storeCoordinator;
        
        return tempMaster;
        }();
    
    internal lazy var mainObjectContext: NSManagedObjectContext = {
        var tempMain = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType);
        tempMain.persistentStoreCoordinator = self.storeCoordinator;
        
        return tempMain;
        }();
    
    private lazy var storeCoordinator: NSPersistentStoreCoordinator = {
        
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil);
        var tempStoreCordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!);
        
        let tempURLS = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask);
        
        let storeURL = (tempURLS[tempURLS.count - 1]).URLByAppendingPathComponent(kStorePathComponent);
        
        var error: NSError?;
        tempStoreCordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error);
        
        if error != nil {
            NSLog("\(error)");
        }
        
        return tempStoreCordinator;
        }();
}
