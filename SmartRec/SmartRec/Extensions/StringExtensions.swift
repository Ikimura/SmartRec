//
//  StringExtensions.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/21/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation

extension NSString {
    
    class func randomString() -> String! {
        let uuid = NSUUID().UUIDString;
        
        return uuid;
    }
    
    class func stringFromDate(date: NSDate, withFormat format: String) -> String! {
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = format;
        
        let result = "MOV_\(dateFormatter.stringFromDate(date))";
        
        return result.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
    
}