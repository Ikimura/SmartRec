//
//  SRBaseMapMarker.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 1/30/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRBaseMapMarker: GMSMarker {
    let routeID: String;
    
    init(routeID: String) {
        self.routeID = routeID;
        
        super.init()
    }
}