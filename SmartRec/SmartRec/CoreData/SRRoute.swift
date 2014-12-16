//
//  SRRoute.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/16/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

public class SRRoute: NSManagedObject {

    @NSManaged var data: NSData
    @NSManaged var duration: NSNumber
    @NSManaged var id: String
    @NSManaged var startDate: NSNumber
    @NSManaged var routePoints: NSOrderedSet
    @NSManaged var videoMarks: NSSet

    func addMark(mark: SRVideoMark) {
        var tempSet: NSMutableSet = NSMutableSet(set: videoMarks);
        tempSet.addObject(mark);
        videoMarks = tempSet;
    }
    
    func addRoutePoint(point: SRRoutePoint) {
        var tempSet: NSMutableOrderedSet = NSMutableOrderedSet(orderedSet: routePoints);
        
        tempSet.addObject(point);
        
        routePoints = tempSet;
    }
}
