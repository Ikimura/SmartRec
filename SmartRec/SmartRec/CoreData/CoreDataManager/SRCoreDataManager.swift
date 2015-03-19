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
    
    class var sharedInstance: SRCoreDataManager {
        struct Static {
            static let instance: SRCoreDataManager = SRCoreDataManager();
        }
        return Static.instance;
    }
    
    //MARK: - life cycle
    
    override init() {
        super.init();
        
    }

    //MARK: - new public API
    
    func tempAppointment(appointment: SRAppointment) -> NSManagedObject? {
        var context = SRCoreDataContextProvider.mainManagedObjectContext();
        
        var appointmentEntity: SRCoreDataAppointment? = NSEntityDescription.insertNewObjectForEntityForName("SRCoreDataAppointment", inManagedObjectContext: context) as? SRCoreDataAppointment;
        
        var placeEntity: SRCoreDataPlace? = NSEntityDescription.insertNewObjectForEntityForName("SRCoreDataPlace", inManagedObjectContext: context) as? SRCoreDataPlace;
        
        if (appointmentEntity != nil && placeEntity != nil) {
            
            appointmentEntity?.fillAppointmentPropertiesWith(appointment);
            placeEntity?.fillPropertiesFromStruct(appointment.place);
            
            //add relashioships
            appointmentEntity!.place = placeEntity!;
            placeEntity!.addAppointment(appointmentEntity!);
            
            return appointmentEntity;
        }
        
        return nil;
    }
    
    func insertAppointment(appointment: SRAppointment) -> SRResult {
        
        var context = SRCoreDataContextProvider.mainManagedObjectContext();
        
        var appointmentEntity: SRCoreDataAppointment? = NSEntityDescription.insertNewObjectForEntityForName("SRCoreDataAppointment", inManagedObjectContext: context) as? SRCoreDataAppointment;
        
        var placeEntity: SRCoreDataPlace? = NSEntityDescription.insertNewObjectForEntityForName("SRCoreDataPlace", inManagedObjectContext: context) as? SRCoreDataPlace;
        
        if (appointmentEntity != nil && placeEntity != nil) {
            
            appointmentEntity?.fillAppointmentPropertiesWith(appointment);
            placeEntity?.fillPropertiesFromStruct(appointment.place);
            
            //add relashioships
            appointmentEntity!.place = placeEntity!;
            placeEntity!.addAppointment(appointmentEntity!);
            
            var error: NSError?;
            context.save(&error);
            
            if error != nil {
                
                return .Failure(error!);
            }
            
            return .Success(true);
        }
        
        return .Failure(NSError(domain: "SRCoreDataManagerInsertDomain", code: -57, userInfo: nil));
    }
    

    func addRelationBetweenVideoData(videoDataStruct: SRVideoDataStruct, andRouteMark identifier: String) -> SRResult {
        
        var workingContext = SRCoreDataContextProvider.workingManagedObjectContext();

        if var videoMark = self.singleManagedObject(kManagedObjectVideoMark, withUniqueField: identifier, inContext: workingContext) as? SRRouteVideoPoint {
            
            var videoData: SRVideoData? = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectVideoData, inManagedObjectContext: workingContext) as? SRVideoData;

            if (videoData != nil) {

                println("SRVideoData")
                videoData!.fillPropertiesFromStruct(videoDataStruct);
            }
            
            videoMark.videoData = videoData;
            
            var saved = SRCoreDataContextProvider.saveWorkingContext(workingContext);
            if (saved) {
                return .Success(true);
            } else {
                return .Failure(NSError(domain: "SRCoreDataManagerAddRelashionship", code: -69, userInfo: nil));
            }
        }
        
        return .Failure(NSError(domain: "SRCoreDataManagerAddRelashionship", code: -67, userInfo: nil));
    }
    
    func addRelationBetweenRoutePoint(routePoint: Any, andRoute identifier: String) -> SRResult {

        var workingContext = SRCoreDataContextProvider.workingManagedObjectContext();

        if var route = self.singleManagedObject(kManagedObjectRoute, withUniqueField: identifier, inContext: workingContext) as? SRRoute {
            
            var point: NSManagedObject? = nil;
            
            if routePoint is SRRoutePointStruct {
                
                point = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectRoutePoint, inManagedObjectContext: workingContext) as? SRRoutePoint;
                
                (point as SRRoutePoint).fillPropertiesFromStruct(routePoint as SRRoutePointStruct);
                route.addRoutePoint(point as SRRoutePoint);

            } else if (routePoint is SRVideoMarkStruct) {
                
                point = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectVideoMark, inManagedObjectContext: workingContext) as? SRRouteVideoPoint;
                
                (point as SRRouteVideoPoint).fillPropertiesFromStruct(routePoint as SRVideoMarkStruct);
                route.addMark(point as SRRouteVideoPoint);

            }
            
            (point as SRRoutePoint).route = route;
            
            var saved = SRCoreDataContextProvider.saveWorkingContext(workingContext);
            if (saved) {
                return .Success(true);
            } else {
                return .Failure(NSError(domain: "SRCoreDataManagerAddRelashionship", code: -79, userInfo: nil));
            }
        }
        
        return .Failure(NSError(domain: "SRCoreDataManagerAddRelashionship", code: -77, userInfo: nil));
    }
    
    func updateEntity(entity: NSManagedObject) -> SRResult {
        var managedContext = entity.managedObjectContext;
                
        var error: NSError?;
        
        if (managedContext?.save(&error) == true) {
            return .Success(true);
        }
        
        return .Failure(error!);
    }
    
    func deleteEntity(entity: String, withUniqueField indentifier: String, fromContext context: NSManagedObjectContext) -> SRResult {
        
        var entity = self.singleManagedObject(entity, withUniqueField: indentifier, inContext: context);
        
        return self.deleteEntity(entity!);
    }
    
    func deleteEntity(entity: NSManagedObject) -> SRResult {
        
        var context = entity.managedObjectContext;
        context?.delete(entity);
        
        var error: NSError?;
        if (context?.save(&error) == true) {
            return .Success(true);
        }
        
        return .Failure(error!);
    }
    
    //MARK: - Utils
    
    func singleManagedObject(entityName: String, withUniqueField identifier: String, inContext context: NSManagedObjectContext) -> NSManagedObject? {
        
        var predicate: NSPredicate?
        if (entityName == "SRCoreDataPlace") {
            
            predicate = NSPredicate(format: "placeId == %@", identifier)!;

        } else {
            
            predicate = NSPredicate(format: "id == %@", identifier)!;
        }
        
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: entityName);
        fetchRequest.predicate = predicate;
        
        var error: NSError?;
        var res: AnyObject? = context.executeFetchRequest(fetchRequest, error: &error)?.first;
        
        if error != nil {
            println(error);
        }
        
        return res as? NSManagedObject;
    }
    
    func findOrCreateManagedObject(entityName: String, predicate: NSPredicate, inContext: NSManagedObjectContext) -> NSManagedObject {
        
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: entityName);
        fetchRequest.predicate = predicate;
        fetchRequest.fetchLimit = 1;
        
        var route: AnyObject? = inContext.executeFetchRequest(fetchRequest, error: nil)?.first;
        
        if (route == nil) {
            
            route = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: inContext) as? NSManagedObject;
        }
        
        return route! as NSManagedObject;
    }
    
}
