//
//  SRRoutePoint.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/2/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

public class SRRoutePoint: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var time: NSNumber
    @NSManaged var locationDescription: String?
    @NSManaged var route: SRRoute?

}
