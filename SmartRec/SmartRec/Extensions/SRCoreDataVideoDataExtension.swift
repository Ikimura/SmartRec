//
//  SRCoreDataVideoDataExtension.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/18/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

extension SRVideoData {
    
    func fillPropertiesFromStruct(videoDataStruct: SRVideoDataStruct) {
        
        self.id = videoDataStruct.id;
        self.fileName = videoDataStruct.fileName;
        self.date = NSDate(timeIntervalSince1970: videoDataStruct.dateSeconds);
        self.fileSize = NSNumber(longLong: videoDataStruct.fileSize);
        self.duration = NSNumber(double: videoDataStruct.duration);
        self.frameRate = NSNumber(float: videoDataStruct.frameRate);
        self.resolutionHeight = NSNumber(int: videoDataStruct.resHeight);
        self.resolutionWidth = NSNumber(int: videoDataStruct.resWidth);
    }
}