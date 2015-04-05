//
//  SRRoutePoint.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/15/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRRoutePoint: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var latitude: NSNumber
    @NSManaged var locationDescription: String?
    @NSManaged var longitude: NSNumber
    @NSManaged var time: NSDate
    @NSManaged var route: SRCoreDataRoute?

}
