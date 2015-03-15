//
//  SRRoute.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/15/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRRoute: NSManagedObject {

    @NSManaged var duration: NSNumber
    @NSManaged var id: String
    @NSManaged var startDate: NSNumber
    @NSManaged var routePoints: NSOrderedSet
    @NSManaged var videoPoints: NSOrderedSet

}
