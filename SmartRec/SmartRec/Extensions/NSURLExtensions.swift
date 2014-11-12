//
//  NSURLExtensions.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/28/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation

public extension NSURL {
    
    class func URL(#directoryName: NSSearchPathDirectory, fileName: String) -> NSURL? {
        
        let paths = NSSearchPathForDirectoriesInDomains(directoryName, .UserDomainMask, true)
        var url: NSURL?;
        
        if let documentsDirectory = paths[0] as? String {
            var filePath = "\(documentsDirectory)/\(fileName)";
            
            if let nonNilURL = NSURL(fileURLWithPath: filePath) as NSURL! {
                return nonNilURL;
            }
        }
        
        return url;
    }
}