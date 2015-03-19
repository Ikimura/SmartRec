//
//  SRCoreDataVideoPointExtensions.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/18/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

extension SRRouteVideoPoint {
    
    func fillPropertiesFromStruct(videoPointStruct: SRVideoMarkStruct) {

        self.id = videoPointStruct.id;
        self.latitude = videoPointStruct.lat;
        self.longitude = videoPointStruct.lng;
        self.autoSaved = videoPointStruct.autoSave;
        
        if let imageData = videoPointStruct.image as NSData! {
            self.thumbnailImage = imageData;
        }
    }
}