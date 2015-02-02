//
//  SRVideoData.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/2/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

public class SRVideoData: NSManagedObject {

    @NSManaged var date: NSNumber
    @NSManaged var duration: NSNumber
    @NSManaged var fileName: String
    @NSManaged var fileSize: NSNumber
    @NSManaged var frameRate: NSNumber
    @NSManaged var id: String
    @NSManaged var resolutionHeight: NSNumber
    @NSManaged var resolutionWidth: NSNumber

}
