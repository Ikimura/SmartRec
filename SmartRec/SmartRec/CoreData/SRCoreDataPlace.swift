//
//  SRCoreDataPlace.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 4/5/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRCoreDataPlace: NSManagedObject {

    @NSManaged var distance: Float
    @NSManaged var formattedAddress: String?
    @NSManaged var formattedPhoneNumber: String?
    @NSManaged var fullData: Bool
    @NSManaged var iconURL: String
    @NSManaged var internalPhoneNumber: String?
    @NSManaged var lat: Double
    @NSManaged var lng: Double
    @NSManaged var name: String
    @NSManaged var photoReference: String?
    @NSManaged var placeId: String
    @NSManaged var reference: String
    @NSManaged var vicinity: String?
    @NSManaged var website: String?
    @NSManaged var weekdayText: String?
    @NSManaged var types: String
    @NSManaged var appointments: NSSet

}
