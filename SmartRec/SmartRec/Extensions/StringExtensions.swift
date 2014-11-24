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
        
        var s = NSMutableData(length: 16);
        let result = SecRandomCopyBytes(kSecRandomDefault, UInt(s!.length), UnsafeMutablePointer<UInt8>(s!.mutableBytes))
        
        let base64str = s!.base64EncodedStringWithOptions(nil);
        
        return base64str;
    }
    
    class func stringFromDate(date: NSDate, withFormat format: String) -> String! {
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = format;
        
        let result = "MOV_\(dateFormatter.stringFromDate(date))";
        
        return result.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
    
}