//
//  SRRouteFunctionality.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/2/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

extension SRCoreDataRoute {
    
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
        self.startDate = routeStruct.dateSeconds;
        self.mode = routeStruct.mode;
    }
}