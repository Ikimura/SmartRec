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
    
    //MARK: lazy properties
    
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
    
//    private var operationQueue: NSOperationQueue?;
    
    //MARK: life cicle
    
    public override init() {
        super.init();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mocDidSaveNotification:", name: NSManagedObjectContextDidSaveNotification, object: nil);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: nil);
    }
    
    //FIXME: with generic
    
    internal func insertObjcet(data: [String: AnyObject]) {
        
        var entity = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectNote, inManagedObjectContext: mainObjectContext) as SRNote;
        
        entity.id = data["id"] as String;
        entity.fileName = data["name"] as String;
        entity.date = data["date"] as NSDate;
        entity.imageThumbnail = data["thumbnailImage"] as NSData;
        
        self.saveContext(mainObjectContext);
    }
    
    //MARK: private methids
    
    private func saveContext(context: NSManagedObjectContext) {
        
        context.performBlockAndWait { [unowned context] () -> Void in
            var error: NSError?;
            if context.save(&error) == false {
                println(error);
            }
        };
    }
    
    //MARK: save notification

    func mocDidSaveNotification(notification: NSNotification) {
        if let savedContext = notification.object as? NSManagedObjectContext {
        // ignore change notifications for the main MOC
            if (masterObjectContext !== savedContext){
                saveContext(masterObjectContext);
            }
        }
    }
    
}
