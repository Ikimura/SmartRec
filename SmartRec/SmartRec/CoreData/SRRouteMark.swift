//
//  SRRouteMark.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/8/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

//FIXME:- rename to SRRoutePoint
public class SRRouteMark: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var time: NSDate

}
