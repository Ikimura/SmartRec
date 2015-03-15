//
//  SRRouteFunctionality.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/2/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

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
    
}