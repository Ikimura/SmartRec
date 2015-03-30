//
//  SRCoreDataAppointment.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/30/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRCoreDataAppointment: NSManagedObject {

    @NSManaged var calendarId: String?
    @NSManaged var completed: Bool
    @NSManaged var fireDate: NSTimeInterval
    @NSManaged var id: String
    @NSManaged var locationTrack: Bool
    @NSManaged var note: String
    @NSManaged var sortDate: NSTimeInterval
    @NSManaged var place: SRCoreDataPlace
    @NSManaged var routes: NSOrderedSet?

}
