//
//  SRNote.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/12/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRNote: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var fileName: String
    @NSManaged var id: String
    @NSManaged var imageThumbnail: NSData

}
