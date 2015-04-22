//
//  SRCoreDataVideoDataExtension.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/18/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

extension SRCoreDataVideoData {
    
    func fillPropertiesFromStruct(videoDataStruct: SRVideoDataStruct) {
        
        self.id = videoDataStruct.id;
        self.fileName = videoDataStruct.fileName;
        self.date = videoDataStruct.dateSeconds;
        self.fileSize = videoDataStruct.fileSize;
        self.duration = videoDataStruct.duration;
        self.frameRate = videoDataStruct.frameRate;
        self.resolutionHeight = videoDataStruct.resHeight;
        self.resolutionWidth = videoDataStruct.resWidth;
    }
}