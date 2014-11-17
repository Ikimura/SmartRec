//
//  SRVideoData.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/17/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRVideoData: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var fileName: String
    @NSManaged var id: String
    @NSManaged var imageThumbnail: NSData
    @NSManaged var location: NSData
    @NSManaged var newRelationship: SRRoute

}
