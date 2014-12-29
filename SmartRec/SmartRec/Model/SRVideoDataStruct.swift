//
//  SRVideoDataStruct.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/12/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation

public struct SRVideoDataStruct {
    var id: String;
    var fileName: String;
    var dateSeconds: NSTimeInterval;
    var fileSize: Int64;
    var frameRate: Float;
    var duration: Double;
    var resHeight: Int32;
    var resWidth: Int32;
    
    init(id: String, fileName: String, dateSeconds: NSTimeInterval) {
        self.id = id;
        self.fileName = fileName;
        self.dateSeconds = dateSeconds;
        self.fileSize = 0;
        self.frameRate = 0.0;
        self.duration = 0.0;
        self.resHeight = 0;
        self.resWidth = 0;
    }
}