//
//  SRVideoData.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/29/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRVideoData: NSManagedObject {

    @NSManaged var date: NSNumber
    @NSManaged var fileName: String
    @NSManaged var id: String
    @NSManaged var fileSize: NSNumber
    @NSManaged var frameRate: NSNumber
    @NSManaged var duration: NSNumber
    @NSManaged var resolutionHeight: NSNumber
    @NSManaged var resolutionWidth: NSNumber

}
