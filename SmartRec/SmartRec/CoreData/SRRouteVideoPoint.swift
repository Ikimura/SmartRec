//
//  SRRouteVideoPoint.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/15/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRRouteVideoPoint: SRRoutePoint {

    @NSManaged var autoSaved: NSNumber
    @NSManaged var thumbnailImage: NSData
    @NSManaged var videoData: SRVideoData?

}
