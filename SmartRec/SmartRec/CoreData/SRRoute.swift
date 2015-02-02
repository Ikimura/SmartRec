//
//  SRRoute.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/2/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

public class SRRoute: NSManagedObject {

    @NSManaged var data: NSData
    @NSManaged var duration: NSNumber
    @NSManaged var id: String
    @NSManaged var startDate: NSNumber
    @NSManaged var routePoints: NSOrderedSet
    @NSManaged var videoMarks: NSOrderedSet

}
