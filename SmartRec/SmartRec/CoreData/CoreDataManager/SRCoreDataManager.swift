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
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    //MARK: - new public API
    
    public func insertVideoMarkEntity(dataStruct: SRVideoMarkStruct) -> NSManagedObject? {
        var entity: SRVideoMark? = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectVideoMark, inManagedObjectContext: self.mainObjectContext) as? SRVideoMark;
        
        println("SRVideoMark")
        if entity != nil {
            entity!.id = dataStruct.id;
            entity!.latitude = dataStruct.lat;
            entity!.longitude = dataStruct.lng;
            entity!.autoSaved = dataStruct.autoSave;
            if let imageData =  dataStruct.image as NSData! {
                entity!.thumnailImage = imageData;
            }
        }
        
        self.saveContext(self.mainObjectContext);
        
        return entity;
    }
    
    public func insertVideoDataEntity(dataStruct: SRVideoDataStruct) -> NSManagedObject? {
        var entity: SRVideoData? = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectVideoData, inManagedObjectContext: self.mainObjectContext) as? SRVideoData;
        
        println("SRVideoData")
        if entity != nil {
            entity!.id = dataStruct.id;
            entity!.fileName = dataStruct.fileName;
            //FIXME: - maybe change to sec
            entity!.date = NSDate(timeIntervalSince1970: dataStruct.dateSeconds);
        }
        
        self.saveContext(self.mainObjectContext);
        
        return entity;
    }
    
    public func insertRouteEntity(dataStruct: SRRouteStruct) -> NSManagedObject? {
        var entity: SRRoute? = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectRoute, inManagedObjectContext: self.mainObjectContext) as? SRRoute;
        
        println("route")
        if entity != nil {
            entity!.id = dataStruct.id;
            //FIXME: - to nstimeinterval
            entity!.startDate = NSDate(timeIntervalSince1970: dataStruct.dateSeconds);
        }
        
        self.saveContext(self.mainObjectContext);

        return entity;
    }
    
    public func addRelationBetweenVideoMark(videoMark: SRVideoMark, andRute identifier: String) {
        
        mainObjectContext.performBlockAndWait { [weak self] () -> Void in
            if var blockSelf = self {
                if var route = blockSelf.checkForExistingEntity(kManagedObjectRoute, withId: identifier, inContext: blockSelf.mainObjectContext) as? SRRoute {
                    route.addMark(videoMark);
                    
                    blockSelf.saveContext(blockSelf.mainObjectContext);

                }
            }
        };
    }

    public func addRelationBetweenVideoData(videoData: SRVideoDataStruct, andRouteMark identifier: String) {
        
        mainObjectContext.performBlockAndWait{ [weak self] () -> Void in
            if var blockSelf = self {
                if var videoMark = blockSelf.checkForExistingEntity(kManagedObjectVideoMark, withId: identifier, inContext: blockSelf.mainObjectContext) as? SRVideoMark {
                    if let videoData = blockSelf.insertVideoDataEntity(videoData) as? SRVideoData {
                        videoMark.videoData = videoData;
                        blockSelf.saveContext(blockSelf.mainObjectContext);
                    }
                }
            }
        };
    }
    
    //MARK: - internal API

    internal func fetchEntities(name: String, withCompletion completion:((fetchResult: NSAsynchronousFetchResult) -> Void))  {
        
        // Initialize Fetch Request
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: name);
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "startDate", ascending: true) ];
        
        // Initialize Asynchronous Fetch Request
        var asynchronousFetchRequest: NSAsynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (result: NSAsynchronousFetchResult!) -> Void in
            //complition
            completion(fetchResult: result);
        };
        
        self.mainObjectContext.performBlock { () -> Void in
            // Execute Asynchronous Fetch Request
            var asynchronousFetchRequestError: NSError?;
            var asynchronousFetchResult: NSAsynchronousFetchResult = self.mainObjectContext.executeRequest(asynchronousFetchRequest, error: &asynchronousFetchRequestError) as NSAsynchronousFetchResult;
            
            if (asynchronousFetchRequestError != nil) {
                NSLog("Unable to execute asynchronous fetch result.");
            }
        }
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
                println(blockContext);
                if blockContext.save(&error) == false {
                    println(error);
                }
            }
        };
    }
    
    //MARK: - save notification

    internal func mocDidSaveNotification(notification: NSNotification) {
        if let savedContext = notification.object as? NSManagedObjectContext {
        // ignore change notifications for the main MOC
            if (self.masterObjectContext !== savedContext){
                self.saveContext(masterObjectContext);
            }
        }
    }
    
}
