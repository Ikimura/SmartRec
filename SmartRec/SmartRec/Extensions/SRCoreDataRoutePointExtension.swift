//
//  SRCoreDataRoutePointExtension.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/18/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

extension SRRoutePoint {
    
    func fillPropertiesFromStruct(pointStruct: SRRoutePointStruct) {
        
        self.id = pointStruct.id;
        self.latitude = pointStruct.lat;
        self.longitude = pointStruct.lng;
        self.time = NSDate(timeIntervalSince1970: pointStruct.time);
        
        if (pointStruct.longDescription != nil) {
            
            self.locationDescription = pointStruct.longDescription;
        }
    }
}
