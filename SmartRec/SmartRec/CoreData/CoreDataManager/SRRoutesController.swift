//
//  SRRoutesController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 4/5/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRRoutesController {
    
    class var sharedInstance: SRRoutesController {
        struct Static {
            static let instance: SRRoutesController = SRRoutesController();
        }
        return Static.instance;
    }
    
    private lazy var googleServicesProvider: SRGoogleServicesDataProvider = {
        var tempProvider = SRGoogleServicesDataProvider();
        return tempProvider;
    }();
    
    private lazy var serialQueue: dispatch_queue_t = {
        
        return dispatch_queue_create("com.routeSerrializeData.serialQueue", DISPATCH_QUEUE_SERIAL);
    }();
    
    func insertRouteEntity(dataStruct: SRRouteStruct, complitionBlock: (routeId:  String) -> Void) {
        
        dispatch_async(self.serialQueue, { [weak self]() -> Void in
            
            var workingContext = SRCoreDataContextProvider.workingManagedObjectContext();
            
            var route: SRCoreDataRoute? = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectRoute, inManagedObjectContext: workingContext) as? SRCoreDataRoute;
            
            if (route != nil) {
                
                route!.fillPropertiesFromStruct(dataStruct);
            }
            
            var saved = SRCoreDataContextProvider.saveWorkingContext(workingContext);
            
            if (saved) {
                
                complitionBlock(routeId: route!.id);
                
            } else {
                
                fatalError("cant save route");
            }
        });
    }
    
    func deleteRouteWithId(routeId: String, complitionBlock: (result:  SRResult) -> Void) {
        
        dispatch_async(self.serialQueue, { [weak self]() -> Void in
            
            var workingContext = SRCoreDataContextProvider.workingManagedObjectContext();
            
            var entity = SRCoreDataManager.sharedInstance.singleManagedObject(kManagedObjectRoute, withUniqueField: routeId, inContext: workingContext);
            
            workingContext.deleteObject(entity!);
            
            var saved = SRCoreDataContextProvider.saveWorkingContext(workingContext);
            
            if (saved) {
                
                complitionBlock(result: .Success(true));
                
            } else {
                
                complitionBlock(result: .Failure(NSError(domain: "SRCoreDataManagerDeleteRoute", code: -89, userInfo: nil)));
            }
        });
    }

    func addRelationBetweenVideoData(videoDataStruct: SRVideoDataStruct, andRouteMark identifier: String, complitionBlock: (result:  SRResult) -> Void) {
        
        dispatch_async(self.serialQueue, { [weak self]() -> Void in

            var workingContext = SRCoreDataContextProvider.workingManagedObjectContext();
            
            if var videoMark = SRCoreDataManager.sharedInstance.singleManagedObject(kManagedObjectVideoMark, withUniqueField: identifier, inContext: workingContext) as? SRCoreDataRouteVideoPoint {
                
                var videoData: SRCoreDataVideoData? = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectVideoData, inManagedObjectContext: workingContext) as? SRCoreDataVideoData;
                
                if (videoData != nil) {
                    
                    println("SRCoreDataVideoData")
                    videoData!.fillPropertiesFromStruct(videoDataStruct);
                }
                
                videoMark.videoData = videoData;
                
                var saved = SRCoreDataContextProvider.saveWorkingContext(workingContext);
                if (saved) {
                    
                    complitionBlock(result: .Success(true));
                    
                } else {
                    
                    complitionBlock(result: .Failure(NSError(domain: "SRCoreDataManagerAddRelashionship", code: -69, userInfo: nil)));
                }
            }
            
            complitionBlock(result: .Failure(NSError(domain: "SRCoreDataManagerAddRelashionship", code: -67, userInfo: nil)));
        });
    }
    
    func addRelationBetweenRoutePoint(routePoint: Any, andRoute identifier: String, complitionBlock: (result:  SRResult) -> Void) {
        
        dispatch_async(self.serialQueue, { [weak self]() -> Void in

            var workingContext = SRCoreDataContextProvider.workingManagedObjectContext();
            
            if var route = SRCoreDataManager.sharedInstance.singleManagedObject(kManagedObjectRoute, withUniqueField: identifier, inContext: workingContext) as? SRCoreDataRoute {
                
                var point: NSManagedObject? = nil;
                
                if routePoint is SRRoutePointStruct {
                    
                    point = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectRoutePoint, inManagedObjectContext: workingContext) as? SRCoreDataRoutePoint;
                    
                    (point as SRCoreDataRoutePoint).fillPropertiesFromStruct(routePoint as SRRoutePointStruct);
                    route.addRoutePoint(point as SRCoreDataRoutePoint);
                    
                } else if (routePoint is SRVideoMarkStruct) {
                    
                    point = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectVideoMark, inManagedObjectContext: workingContext) as? SRCoreDataRouteVideoPoint;
                    
                    (point as SRCoreDataRouteVideoPoint).fillPropertiesFromStruct(routePoint as SRVideoMarkStruct);
                    route.addMark(point as SRCoreDataRouteVideoPoint);
                    
                }
                
                (point as SRCoreDataRoutePoint).route = route;
                
                var saved = SRCoreDataContextProvider.saveWorkingContext(workingContext);
                if (saved) {
                    
                    complitionBlock(result: .Success(true));
            
                } else {
                    complitionBlock(result: .Failure(NSError(domain: "SRCoreDataManagerAddRelashionship", code: -79, userInfo: nil)));
                }
            }
            complitionBlock(result: .Failure(NSError(domain: "SRCoreDataManagerAddRelashionship", code: -77, userInfo: nil)));
        });
    }
    
    func googleDirectionForAppintment(appointmentId: String?, from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, mode: String, complitionBlock: (routeId: String?, error: NSError?) -> Void) {
        
        googleServicesProvider.googleDirection(origin, to: destination, mode: mode, complitionBlock: { [weak self](response) -> Void in
            
            if let strongSelf = self {
                
                strongSelf.serrializeRoutesFromResponseDictionary(response, appointmentId: appointmentId, complitionBlock: { (routeId, error) -> Void in
                    
                    complitionBlock(routeId: routeId, error: error);
                    println("Routes parsing has Finished.")
                });
            }
            
        }) { (error) -> Void in
            
            complitionBlock(routeId: nil, error: error);
        }
    }
    
    private func serrializeRoutesFromResponseDictionary(response: Array<NSDictionary>, appointmentId: String?, complitionBlock: (routeId: String?, error: NSError?) -> Void) {
        
        dispatch_async(self.serialQueue, { [weak self]() -> Void in
            
            if let strongSelf = self {
                
                var workingContext = SRCoreDataContextProvider.workingManagedObjectContext();
                
                var appointment: SRCoreDataAppointment? = nil;
                if (appointmentId != nil) {
    
                    appointment = SRCoreDataManager.sharedInstance.singleManagedObject(kManagedObjectAppointment, withUniqueField: appointmentId!, inContext: workingContext) as? SRCoreDataAppointment;
                }
                
                println("results = \(response.count)")
                
                //Creating Route
                var routeEntity = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectRoute, inManagedObjectContext: workingContext) as? SRCoreDataRoute;
                
                let route = response[0];
                var id = route["summary"] as? String;
                var legs = route["legs"] as? Array<NSDictionary>;
                
                var polyline = route["overview_polyline"] as? NSDictionary;
                var overview_route = polyline!["points"] as? String;
                
                var firstLeg = legs![0];
                var distanceDict = firstLeg["distance"] as? NSDictionary;
                var durationDict = firstLeg["duration"] as? NSDictionary;
                
                var distDouble = distanceDict!["value"] as Double!;
                var durDouble = durationDict!["value"] as Double!;
                
                var parseResponse = MapManager.sharedInstance.parser(firstLeg);
                
                var steps = parseResponse["steps"] as Array<NSDictionary>;
                
                //FIXME: CHECK mode
                routeEntity!.fillPropertiesFromStruct(SRRouteStruct(id: String.randomString(), dateSeconds: NSDate().timeIntervalSince1970, mode:"Driving"));
                
                routeEntity!.duration = durDouble;
                routeEntity!.distance = distDouble;
                routeEntity!.googleOverviewPolyline = overview_route;
                
                for var i = 0; i < steps.count; i++ {
                    
                    //start location of step
                    var pointId = NSString.randomString();
                    var pointLocation = steps[i]["start_location"] as? NSDictionary;
                    
                    var pointLat = pointLocation!["lat"] as? Double;
                    var pointLng = pointLocation!["lng"] as? Double;
                    
                    println("Start point: \(pointLat)-\(pointLng)");
                    
                    var pointLongDescription = steps[i]["start_address"] as? String;
                    
                    var point = SRRoutePointStruct(id: pointId,
                        lng: pointLat!,
                        lat: pointLng!,
                        time: NSDate().timeIntervalSince1970,
                        longDescription:pointLongDescription
                    );
                    
                    //ADD relashionship
                    var firstPointEntity = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectRoutePoint, inManagedObjectContext: workingContext) as? SRCoreDataRoutePoint;
                    firstPointEntity?.fillPropertiesFromStruct(point);
                    
                    routeEntity?.addRoutePoint(firstPointEntity!);
                    
                    pointId = NSString.randomString();
                    pointLocation = steps[i]["end_location"] as? NSDictionary;
                    
                    pointLat = pointLocation!["lat"] as? Double;
                    pointLng = pointLocation!["lng"] as? Double;
                    
                    println("Start point: \(pointLat)-\(pointLng)");
                    
                    pointLongDescription = steps[i]["end_address"] as? String;
                    
                    point = SRRoutePointStruct(id: pointId,
                        lng: pointLat!,
                        lat: pointLng!,
                        time: NSDate().timeIntervalSince1970,
                        longDescription:pointLongDescription
                    );
                    
                    //ADD relashionship
                    var secondPointEntity = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectRoutePoint, inManagedObjectContext: workingContext) as? SRCoreDataRoutePoint;
                    secondPointEntity?.fillPropertiesFromStruct(point);
                    
                    routeEntity?.addRoutePoint(secondPointEntity!);
                }
                
                if (appointment != nil) {
                    
                    routeEntity!.appointment = appointment!;
                    
                    if (appointment?.routes?.count == 2) {
                        
                        SRCoreDataManager.sharedInstance.deleteEntity(appointment!.routes!.firstObject as NSManagedObject);
                        SRCoreDataManager.sharedInstance.deleteEntity(appointment!.routes!.firstObject as NSManagedObject);
                        
                        appointment!.routes = nil;
                    }
                    
                    appointment!.addRoute(routeEntity!);
                }
               
                if (SRCoreDataContextProvider.saveWorkingContext(workingContext)) {

                    complitionBlock(routeId: routeEntity!.id, error: nil);
                    
                } else {
                    
                    fatalError("Bad route")
                }
            }
        });
    }
}