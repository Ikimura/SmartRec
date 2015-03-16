//
//  SRCoreDataManager.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/13/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import CoreData

class SRCoreDataManager: NSObject {
    
    private var storePath: String!;
    
    //MARK: - lazy properties
    
    lazy var masterObjectContext: NSManagedObjectContext = {
        var tempMaster = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType);
        tempMaster.persistentStoreCoordinator = self.storeCoordinator;
        
        return tempMaster;
    }();
    
    lazy var mainObjectContext: NSManagedObjectContext = {
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
    
    //MARK: - life cycle
    
    init(storePath: String) {
        super.init();
        
        self.storePath = storePath;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mocDidSaveNotification:", name: NSManagedObjectContextDidSaveNotification, object: self.mainObjectContext);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    //MARK: - new public API
    
    func fillAppointmentPropertiesWith(appintmentData: SRAppointment) -> SRCoreDataAppointment? {
        
        var entity: SRCoreDataAppointment? = NSEntityDescription.insertNewObjectForEntityForName("SRCoreDataAppointment", inManagedObjectContext: self.mainObjectContext) as? SRCoreDataAppointment;
        
        var placeEntity: SRCoreDataPlace? = self.checkForExistingEntity("SRCoreDataPlace", withId: appintmentData.place.placeId, inContext: self.mainObjectContext) as? SRCoreDataPlace;
        
        if (placeEntity == nil) {
            
            placeEntity = NSEntityDescription.insertNewObjectForEntityForName("SRCoreDataPlace", inManagedObjectContext: self.mainObjectContext) as? SRCoreDataPlace;
        }
        
        if (entity != nil && placeEntity != nil) {
            
            placeEntity!.reference = appintmentData.place.reference;
            placeEntity!.placeId = appintmentData.place.placeId;
            placeEntity!.name = appintmentData.place.name!;
            placeEntity!.lat = NSNumber(double: appintmentData.place.lat);
            placeEntity!.lng = NSNumber(double: appintmentData.place.lng);
            placeEntity!.iconURL = appintmentData.place.iconURL!.absoluteString!;
            
            if (appintmentData.place.photoReferences?.count != 0) {
                
                placeEntity?.photoReference = appintmentData.place.photoReferences![0];
            }
            
            if (appintmentData.place.vicinity != nil) {
                
                placeEntity!.vicinity = appintmentData.place.vicinity!;
            }

            placeEntity!.formattedAddress = appintmentData.place.formattedAddress!;
            
            if (appintmentData.place.formattedPhoneNumber != nil) {
                placeEntity!.formattedPhoneNumber = appintmentData.place.formattedPhoneNumber!;
            }
            
            if (appintmentData.place.internalPhoneNumber != nil) {
                placeEntity!.internalPhoneNumber = appintmentData.place.internalPhoneNumber!;
            }
            
            if (appintmentData.place.distance != nil) {
                placeEntity!.distance = appintmentData.place.distance!;
            }
            
            if (appintmentData.place.website != nil) {
                placeEntity!.website = appintmentData.place.website!;
            }
            
//            if (appintmentData.place.zipCity != nil) {
//                placeEntity!.zipCity = appintmentData.place.zipCity!;
//            }
            
            if (appintmentData.calendarId != nil) {
                entity!.calendarId = appintmentData.calendarId!;
            }
            
            
            entity!.locationTrack = NSNumber(bool: appintmentData.locationTrack);
            let fireDate = NSDate(timeIntervalSince1970: appintmentData.dateInSeconds);
            entity!.fireDate = fireDate;
            entity!.sortDate = NSCalendar.currentCalendar().startOfDayForDate(fireDate);
            entity!.note = appintmentData.description;
            entity!.place = placeEntity!;
            println("\(appintmentData.id)");
            entity!.id = "\(appintmentData.id)";
            entity!.completed = NSNumber(bool: false);
            
            placeEntity?.addAppointment(entity!);
        }
        
        return entity;
        
//        self.saveContext(self.mainObjectContext);
//        complitionBlock(entity: entity!, error: nil);
    }
    
    func insertVideoMarkEntity(dataStruct: SRVideoMarkStruct) -> NSManagedObject? {
        var entity: SRRouteVideoPoint? = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectVideoMark, inManagedObjectContext: self.mainObjectContext) as? SRRouteVideoPoint;
        
        println("SRVideoMark")
        if entity != nil {
            entity!.id = dataStruct.id;
            entity!.latitude = dataStruct.lat;
            entity!.longitude = dataStruct.lng;
            entity!.autoSaved = dataStruct.autoSave;
            if let imageData =  dataStruct.image as NSData! {
                entity!.thumbnailImage = imageData;
            }
        }
        
        self.saveContext(self.mainObjectContext);
        
        return entity;
    }
    
    func insertRoutePointEntity(dataStruct: SRRoutePointStruct) -> NSManagedObject? {
        var entity: SRRoutePoint? = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectRoutePoint, inManagedObjectContext: self.mainObjectContext) as? SRRoutePoint;
        
        println("SRRoutePOint")
        if entity != nil {
            entity!.id = dataStruct.id;
            entity!.latitude = dataStruct.lat;
            entity!.longitude = dataStruct.lng;
            entity!.time = NSDate(timeIntervalSince1970: dataStruct.time);
        }
        
        self.saveContext(self.mainObjectContext);
        
        return entity;
    }
    
    func insertVideoDataEntity(dataStruct: SRVideoDataStruct) -> NSManagedObject? {
        var entity: SRVideoData? = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectVideoData, inManagedObjectContext: self.mainObjectContext) as? SRVideoData;
        
        println("SRVideoData")
        if entity != nil {
            entity!.id = dataStruct.id;
            entity!.fileName = dataStruct.fileName;
            entity!.date = NSDate(timeIntervalSince1970: dataStruct.dateSeconds);
            entity!.fileSize = NSNumber(longLong: dataStruct.fileSize);
            entity!.duration = NSNumber(double: dataStruct.duration);
            entity!.frameRate = NSNumber(float: dataStruct.frameRate);
            entity!.resolutionHeight = NSNumber(int: dataStruct.resHeight);
            entity!.resolutionWidth = NSNumber(int: dataStruct.resWidth);
        }
        
        self.saveContext(self.mainObjectContext);
        
        return entity;
    }
    
    func insertRouteEntity(dataStruct: SRRouteStruct) -> NSManagedObject? {
        var entity: SRRoute? = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectRoute, inManagedObjectContext: self.mainObjectContext) as? SRRoute;
        
        println("route")
        if entity != nil {
            entity!.id = dataStruct.id;
            entity!.startDate = NSDate(timeIntervalSince1970: dataStruct.dateSeconds);
        }
        
        self.saveContext(self.mainObjectContext);

        return entity;
    }
    
    func addRelationBetweenVideoMark(videoMark: SRRouteVideoPoint, andRute identifier: String) {
        
        mainObjectContext.performBlockAndWait { [weak self] () -> Void in
            if var blockSelf = self {
                if var route = blockSelf.checkForExistingEntity(kManagedObjectRoute, withId: identifier, inContext: blockSelf.mainObjectContext) as? SRRoute {
                    route.addMark(videoMark);
                    videoMark.route = route;
                    
                    blockSelf.saveContext(blockSelf.mainObjectContext);
                }
            }
        };
    }

    func addRelationBetweenVideoData(videoData: SRVideoDataStruct, andRouteMark identifier: String) {
        
        mainObjectContext.performBlockAndWait{ [weak self] () -> Void in
            if var blockSelf = self {
                if var videoMark = blockSelf.checkForExistingEntity(kManagedObjectVideoMark, withId: identifier, inContext: blockSelf.mainObjectContext) as? SRRouteVideoPoint {
                    if let videoData = blockSelf.insertVideoDataEntity(videoData) as? SRVideoData {
                        videoMark.videoData = videoData;
                        blockSelf.saveContext(blockSelf.mainObjectContext);
                    }
                }
            }
        };
    }
    
    func addRelationBetweenRoutePoint(routePoint: SRRoutePoint, andRoute identifier: String) {
        
        mainObjectContext.performBlockAndWait { [weak self] () -> Void in
            if var blockSelf = self {
                if var route = blockSelf.checkForExistingEntity(kManagedObjectRoute, withId: identifier, inContext: blockSelf.mainObjectContext) as? SRRoute {
                    route.addRoutePoint(routePoint);
                    routePoint.route = route;
                    
                    blockSelf.saveContext(blockSelf.mainObjectContext);
                    
                }
            }
        };
    }
    
    func updateEntity(entity: NSManagedObject) -> SRResult {
        var managedContext = entity.managedObjectContext;
                
        var error: NSError?;
        
        if (managedContext?.save(&error) == true) {
            return .Success(true);
        }
        
        return .Failure(error!);
    }
    
    func deleteEntity(entity: NSManagedObject) -> SRResult {
        
        var managedContext = entity.managedObjectContext;
        
        managedContext?.deleteObject(entity);
        
        var error: NSError?;
        
        if (managedContext?.save(&error) == true) {
            return .Success(true);
        }
        
        return .Failure(error!);
    }
    
    //MARK: - internal API

    func fetchEntities(name: String, withCompletion completion:((fetchResult: NSAsynchronousFetchResult) -> Void))  {
        
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
    
    func checkForExistingEntity(name: String, withId identifier: String, inContext context: NSManagedObjectContext) -> NSManagedObject? {
        var fetchRequest: NSFetchRequest = NSFetchRequest();
        let entity: NSEntityDescription = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!;
        
        fetchRequest.entity = entity;
        
        var predicate: NSPredicate?
        if (name == "SRCoreDataPlace") {
            
            predicate = NSPredicate(format: "placeId == %@", identifier)!;

        } else {
            
            predicate = NSPredicate(format: "id == %@", identifier)!;
        }
        
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
