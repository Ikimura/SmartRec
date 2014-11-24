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
    
    //MARK: - lazy properties
    
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
    
    //MARK: - life cycle
    
    public override init() {
        super.init();
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mocDidSaveNotification:", name: NSManagedObjectContextDidSaveNotification, object: nil);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: nil);
    }
    
    //FIXME: with generic
    
    private func insertVideoData(data: [String: AnyObject]) -> SRVideoData! {
        var videoDataEntity = NSEntityDescription.insertNewObjectForEntityForName("SRVideoData", inManagedObjectContext: self.mainObjectContext) as SRVideoData;
        videoDataEntity.id = data["id"] as String;
        videoDataEntity.fileName = data["name"] as String;
        videoDataEntity.date = data["date"] as NSDate;
        
        return videoDataEntity;
    }
    
    private func insertVideoMark(markData: [String: AnyObject]) -> SRVideoMark! {
        
        var videoMarkEntity = NSEntityDescription.insertNewObjectForEntityForName("SRVideoMark", inManagedObjectContext: self.mainObjectContext) as SRVideoMark;
        
        videoMarkEntity.id = markData["id"] as String;
        videoMarkEntity.latitude = NSNumber(double: markData["lat"] as Double);
        videoMarkEntity.longitude = NSNumber(double: markData["lng"] as Double);
        videoMarkEntity.thumnailImage = markData["image"] as NSData;
        
        return videoMarkEntity;
    }

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
    
    internal func fetchEntities(name: String, withCompletion completion:((result: [AnyObject], error: NSError?) -> Void))  {
        var fetchRequest: NSFetchRequest = NSFetchRequest();
        let entity: NSEntityDescription = NSEntityDescription.entityForName(name, inManagedObjectContext: self.mainObjectContext)!;
        
        fetchRequest.entity = entity;
        
        var error: NSError?;
        
        var res = self.mainObjectContext.executeFetchRequest(fetchRequest, error: &error);
        
        completion(result: res!, error: error?);
    }
    
    internal func insertRoute(data: [String: AnyObject]) {
        var routeEntity = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectRoute, inManagedObjectContext: self.mainObjectContext) as SRRoute;
        routeEntity.id = data["id"] as String;
        routeEntity.startDate = data["date"] as NSDate;
        
        self.saveContext(self.mainObjectContext);
    }
    
    internal func addVideoMark(markData: [String: AnyObject], videoData: [String: AnyObject], routeId: String) {
        
        mainObjectContext.performBlockAndWait { [weak self] () -> Void in
            if var blockSelf = self {
                var route = blockSelf.checkForExistingEntity("SRRoute", withId: routeId, inContext: blockSelf.mainObjectContext) as? SRRoute;
                let videoData = blockSelf.insertVideoData(videoData);
                
                var videoMark = blockSelf.insertVideoMark(markData);
                videoMark.videoData = videoData;
                
                route?.addMark(videoMark);
                
                blockSelf.saveContext(blockSelf.mainObjectContext);
            }
        };
    }
    
    //MARK: - private methods
    
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
                saveContext(masterObjectContext);
            }
        }
    }
    
}
