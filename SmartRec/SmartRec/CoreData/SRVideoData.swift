//
//  SRVideoData.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/24/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

public class SRVideoData: NSManagedObject {

    @NSManaged var date: NSNumber
    @NSManaged var fileName: String
    @NSManaged var id: String

}
