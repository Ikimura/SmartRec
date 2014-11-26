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
    
    private var storePath: String!;
    
    //MARK: - lazy properties
    
    internal lazy var masterObjectContext: NSManagedObjectContext = {
        var tempMaster = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType);
        tempMaster.persistentStoreCoordinator = self.storeCoordinator;
        
        return tempMaster;
    }();
    
    public lazy var mainObjectContext: NSManagedObjectContext = {
        var tempMain = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType);
        tempMain.persistentStoreCoordinator = self.storeCoordinator;
        
        return tempMain;
    }();
    
    private lazy var storeCoordinator: NSPersistentStoreCoordinator = {
        
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil);
        var tempStoreCordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!);
        //for migration
        let options: [String: Bool] = [
            NSMigratePersistentStoresAutomaticallyOption : true,
            NSInferMappingModelAutomaticallyOption : true
        ];
        
        let tempURLS = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask);
        
        let storeURL = (tempURLS[tempURLS.count - 1]).URLByAppendingPathComponent(self.storePath);
        
        var error: NSError?;
        tempStoreCordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error);
        
        if error != nil {
            NSLog("\(error)");
        }
        
        return tempStoreCordinator;
    }();
    
    //MARK: - life cycle
    
    public init(storePath: String) {
        super.init();
        
        self.storePath = storePath;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mocDidSaveNotification:", name: NSManagedObjectContextDidSaveNotification, object: self.mainObjectContext);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: self.mainObjectContext);
    }

    //MARK: - new public API
    
    public func insertEntity(entityName: String, dectionaryData: [String: Any]) -> NSManagedObject? {
        var entity: NSManagedObject? = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self.masterObjectContext) as? NSManagedObject;
        
        switch entityName {
        case kManagedObjectRoute:
            println("route")
            if var route = entity as? SRRoute {
                route.id = dectionaryData["id"] as String;
                route.startDate = dectionaryData["date"] as NSDate;
            };
        case kManagedObjectVideoMark:
            println("videomark");
            if var mark = entity as? SRVideoMark {
                mark.id = dectionaryData["id"] as String;
                mark.latitude = NSNumber(double: dectionaryData["lat"] as Double);
                mark.longitude = NSNumber(double: dectionaryData["lng"] as Double);
                if let imageData = dectionaryData["image"] as? NSData {
                    mark.thumnailImage = imageData;
                }
            }
        case kManagedObjectVideoData:
            println("video data");
            if var data = entity as? SRVideoData {
                data.id = dectionaryData["id"] as String;
                data.fileName = dectionaryData["name"] as String;
                data.date = dectionaryData["date"] as NSDate;
            }
        default: println("default");
            
        }
        
        self.saveContext(self.mainObjectContext);
        
        return entity;
    }
    
    public func addRelationBetweenVideoMark(videoMark: SRVideoMark, andRute identifier: String) {
        
        mainObjectContext.performBlock { [weak self] () -> Void in
            if var blockSelf = self {
                if var route = blockSelf.checkForExistingEntity(kManagedObjectRoute, withId: identifier, inContext: blockSelf.masterObjectContext) as? SRRoute {
                    route.addMark(videoMark);
                    
                    blockSelf.saveContext(blockSelf.masterObjectContext);
                }
            }
        };
    }

    public func addRelationBetweenVideoData(videoData: [String: Any], andRouteMark identifier: String) {
        
        mainObjectContext.performBlock { [weak self] () -> Void in
            if var blockSelf = self {
                if var videoMark = blockSelf.checkForExistingEntity(kManagedObjectVideoMark, withId: identifier, inContext: blockSelf.masterObjectContext) as? SRVideoMark {
                    if let videoData = blockSelf.insertEntity(kManagedObjectVideoData, dectionaryData: videoData) as? SRVideoData {
                        videoMark.videoData = videoData;
                        
                        blockSelf.saveContext(blockSelf.masterObjectContext);
                    }
                }
            }
        };
    }
    
    //MARK: - internal API

    internal func fetchEntities(name: String, withCompletion completion:((result: [AnyObject], error: NSError?) -> Void))  {
        var fetchRequest: NSFetchRequest = NSFetchRequest();
        let entity: NSEntityDescription = NSEntityDescription.entityForName(name, inManagedObjectContext: self.mainObjectContext)!;
        
        fetchRequest.entity = entity;
        
        var error: NSError?;
        
        var res = self.mainObjectContext.executeFetchRequest(fetchRequest, error: &error);
        
        completion(result: res!, error: error?);
    }
    
    //MARK: - private methods
    
    private func checkForExistingEntity(name: String, withId identifier: String, inContext context: NSManagedObjectContext) -> NSManagedObject? {
        var fetchRequest: NSFetchRequest = NSFetchRequest();
        let entity: NSEntityDescription = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!;
        
        fetchRequest.entity = entity;
        
        let predicate: NSPredicate = NSPredicate(format: "id == %@", identifier)!;
        fetchRequest.predicate = predicate;
        
        var error: NSError?;
        
        var res: AnyObject? = context.executeFetchRequest(fetchRequest, error: &error)?.first;
        
        if error != nil {
            println(error);
        }
        
        return res as? NSManagedObject;
    }
    
    private func saveContext(context: NSManagedObjectContext) {
        
        context.performBlockAndWait { [weak context] () -> Void in
            if var blockContext = context {
                var error: NSError?;
                if blockContext.save(&error) == false {
                    println(error);
                }
            }
        };
    }
    
    //MARK: - save notification

    func mocDidSaveNotification(notification: NSNotification) {
        if let savedContext = notification.object as? NSManagedObjectContext {
        // ignore change notifications for the main MOC
            if (masterObjectContext !== savedContext){
                self.saveContext(masterObjectContext);
            } else {
                self.saveContext(mainObjectContext);
            }
        }
    }
    
}
