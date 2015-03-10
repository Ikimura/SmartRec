//
//  SRCoreDataAppointment.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/11/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRCoreDataAppointment: NSManagedObject {

    @NSManaged var calendarId: String
    @NSManaged var fireDate: NSDate
    @NSManaged var locationTrack: NSNumber
    @NSManaged var note: String
    @NSManaged var sortDate: NSDate
    @NSManaged var place: SmartRec.SRCoreDataPlace

}
