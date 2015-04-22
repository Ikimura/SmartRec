//
//  SRCoreDataRoutePoint.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 4/22/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRCoreDataRoutePoint: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var latitude: Double
    @NSManaged var locationDescription: String?
    @NSManaged var longitude: Double
    @NSManaged var time: NSTimeInterval
    @NSManaged var route: SRCoreDataRoute?

}
