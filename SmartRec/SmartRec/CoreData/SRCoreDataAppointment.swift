//
//  SRCoreDataAppointment.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/9/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRCoreDataAppointment: NSManagedObject {

    @NSManaged var note: String
    @NSManaged var calendarId: String
    @NSManaged var locationTrack: NSNumber
    @NSManaged var fireData: NSDate
    @NSManaged var place: SRCoreDataPlace

}
