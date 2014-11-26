//
//  SRRoute.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/21/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

public class SRRoute: NSManagedObject {

    @NSManaged var data: NSData
    @NSManaged var id: String
    @NSManaged var startDate: NSDate
    @NSManaged var duration: NSNumber
    @NSManaged var videoMarks: NSSet
    @NSManaged var routeMarks: NSSet

    func addMark(mark: SRVideoMark) {
        var tempSet: NSMutableSet = NSMutableSet(set: videoMarks);
        tempSet.addObject(mark);
        
        videoMarks = tempSet;
    }
}
