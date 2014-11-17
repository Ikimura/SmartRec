//
//  SRRoute.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/17/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRRoute: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var data: NSData
    @NSManaged var newRelationship: NSSet

}
