//
//  SRRouteFunctionality.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/2/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

extension SRRoute {
    
    func addMark(mark: SRRouteVideoPoint) {
        
        var tempSet: NSMutableOrderedSet = NSMutableOrderedSet(orderedSet: videoPoints);
        tempSet.addObject(mark);
        
        videoPoints = tempSet;
    }
    
    func addRoutePoint(point: SRRoutePoint) {
        
        var tempSet: NSMutableOrderedSet = NSMutableOrderedSet(orderedSet: routePoints)
        tempSet.addObject(point);
        
        routePoints = tempSet;
    }
    
    
    func fillPropertiesFromStruct(routeStruct: SRRouteStruct) {
        
        self.id = routeStruct.id;
        self.startDate = NSDate(timeIntervalSince1970: routeStruct.dateSeconds);
        self.mode = routeStruct.mode;
    }
    
    class func insertRouteEntity(dataStruct: SRRouteStruct) -> SRRoute {
        
        var workingContext = SRCoreDataContextProvider.workingManagedObjectContext();
        
        var route: SRRoute? = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectRoute, inManagedObjectContext: workingContext) as? SRRoute;
        
        if (route != nil) {
            
            route!.fillPropertiesFromStruct(dataStruct);
        }
        
        var saved = SRCoreDataContextProvider.saveWorkingContext(workingContext);
        
        if (!saved) {
            fatalError("cant save route");
        }
        
        return route!;
    }
    
    class func parseRoutesFromResponse(results: Array<NSDictionary>) {
        
        var workingContext = SRCoreDataContextProvider.workingManagedObjectContext();
        
        println("results = \(results.count)")
        
        var path: GMSPath?;
        
        let route = results[0];
        var id = route["summary"] as? String;
        var legs = route["legs"] as? Array<NSDictionary>;
        
        var firstLeg = legs![0];

        var parseResponse = MapManager.sharedInstance.parser(firstLeg);
        
        var steps = parseResponse["steps"] as Array<NSDictionary>;
        var count = steps.count;
        var routeEntity = NSEntityDescription.insertNewObjectForEntityForName("SRRoute", inManagedObjectContext: workingContext) as? SRRoute;
        
        routeEntity!.fillPropertiesFromStruct(SRRouteStruct(id: String.randomString(), dateSeconds: NSDate().timeIntervalSince1970, mode:"Driving"));
        
        for var i = 0; i < steps.count; i++ {
            
            //start location of step
            var pointId = NSString.randomString();
            var pointLocation = steps[i]["start_location"] as? NSDictionary;
            
            var pointLat = pointLocation!["lat"] as? Double;
            var pointLng = pointLocation!["lng"] as? Double;
            var pointLongDescription = steps[i]["start_address"] as? String;
            
            var point = SRRoutePointStruct(id: pointId,
                lng: pointLat!,
                lat: pointLng!,
                time: NSDate().timeIntervalSince1970,
                longDescription:pointLongDescription
            );
            
            //ADD relashionship
            var firstPointEntity = NSEntityDescription.insertNewObjectForEntityForName("SRRoutePoint", inManagedObjectContext: workingContext) as? SRRoutePoint;
            firstPointEntity?.fillPropertiesFromStruct(point);
            
            routeEntity?.addRoutePoint(firstPointEntity!);
            
            pointId = NSString.randomString();
            pointLocation = steps[i]["end_location"] as? NSDictionary;
            
            pointLat = pointLocation!["lat"] as? Double;
            pointLng = pointLocation!["lng"] as? Double;
            pointLongDescription = steps[i]["end_address"] as? String;
            
            point = SRRoutePointStruct(id: pointId,
                lng: pointLat!,
                lat: pointLng!,
                time: NSDate().timeIntervalSince1970,
                longDescription:pointLongDescription
            );
            
            //ADD relashionship
            var secondPointEntity = NSEntityDescription.insertNewObjectForEntityForName("SRRoutePoint", inManagedObjectContext: workingContext) as? SRRoutePoint;
            secondPointEntity?.fillPropertiesFromStruct(point);
            
            routeEntity?.addRoutePoint(secondPointEntity!);
        }
        
        if !SRCoreDataContextProvider.saveWorkingContext(workingContext) {
            fatalError("Bad route")
        }
    }
}