//
//  SRCoreDataRoute.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 4/5/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRCoreDataRoute: NSManagedObject {

    @NSManaged var duration: Double
    @NSManaged var id: String
    @NSManaged var mode: String
    @NSManaged var startDate: NSTimeInterval
    @NSManaged var distance: Double
    @NSManaged var googleOverviewPolyline: String?
    @NSManaged var appointment: SRCoreDataAppointment
    @NSManaged var routePoints: NSOrderedSet
    @NSManaged var videoPoints: NSOrderedSet

}
