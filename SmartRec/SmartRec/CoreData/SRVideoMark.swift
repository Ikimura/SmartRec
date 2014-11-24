//
//  SRVideoMark.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/21/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRVideoMark: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var thumnailImage: NSData
    @NSManaged var videoData: SRVideoData

}
