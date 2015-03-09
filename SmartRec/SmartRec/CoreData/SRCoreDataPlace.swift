//
//  SRCoreDataPlace.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/9/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRCoreDataPlace: NSManagedObject {

    @NSManaged var placeId: String
    @NSManaged var reference: String
    @NSManaged var lat: NSNumber
    @NSManaged var lng: NSNumber
    @NSManaged var name: String
    @NSManaged var iconURL: String
    @NSManaged var vicinity: String
    @NSManaged var formattedAddress: String
    @NSManaged var formattedPhoneNumber: String
    @NSManaged var internalPhoneNumber: String
    @NSManaged var distance: NSNumber
    @NSManaged var website: String
    @NSManaged var appointments: NSSet

}
