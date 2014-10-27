//
//  VideoItem.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation
import UIKit.UIImage

class VideoItem : NSObject {
    let date: NSDate!;
    let fileName: String!;
    let thumbnailImage: UIImage!;
    
    
    init(date: NSDate, fileName: String, thumbnailImage: UIImage) {
        super.init();
        
        self.date = date;
        self.fileName = fileName;
        self.thumbnailImage = thumbnailImage;
    }
    
}