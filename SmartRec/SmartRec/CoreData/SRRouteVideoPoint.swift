//
//  SRRouteVideoPoint.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 1/30/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

public class SRRouteVideoPoint: SRRoutePoint {

    @NSManaged var autoSaved: NSNumber
    @NSManaged var thumnailImage: NSData
    @NSManaged var videoData: SRVideoData?

}
