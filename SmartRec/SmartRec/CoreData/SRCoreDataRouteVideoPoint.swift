//
//  SRCoreDataRouteVideoPoint.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 4/22/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRCoreDataRouteVideoPoint: SRCoreDataRoutePoint {

    @NSManaged var autoSaved: Bool
    @NSManaged var thumbnailImage: NSData
    @NSManaged var videoData: SRCoreDataVideoData?

}
