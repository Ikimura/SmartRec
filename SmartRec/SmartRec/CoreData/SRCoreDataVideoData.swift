//
//  SRCoreDataVideoData.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 4/22/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRCoreDataVideoData: NSManagedObject {

    @NSManaged var date: NSTimeInterval
    @NSManaged var duration: Double
    @NSManaged var fileName: String
    @NSManaged var fileSize: Int64
    @NSManaged var frameRate: Float
    @NSManaged var id: String
    @NSManaged var resolutionHeight: Int32
    @NSManaged var resolutionWidth: Int32

}
