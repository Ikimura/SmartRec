//
//  SRRoute.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/18/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRRoute: NSManagedObject {

    @NSManaged var duration: NSNumber
    @NSManaged var id: String
    @NSManaged var startDate: NSDate
    @NSManaged var mode: String
    @NSManaged var appointment: SRCoreDataAppointment?
    @NSManaged var routePoints: NSOrderedSet
    @NSManaged var videoPoints: NSOrderedSet

}
