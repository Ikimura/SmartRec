//
//  SRCoreDataAppointment.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/17/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRCoreDataAppointment: NSManagedObject {

    @NSManaged var calendarId: String?
    @NSManaged var completed: NSNumber
    @NSManaged var fireDate: NSDate
    @NSManaged var id: String
    @NSManaged var locationTrack: NSNumber
    @NSManaged var note: String
    @NSManaged var sortDate: NSDate
    @NSManaged var place: SRCoreDataPlace
    @NSManaged var routes: NSOrderedSet?

}
