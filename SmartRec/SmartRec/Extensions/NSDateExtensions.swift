//
//  NSDateExtensions.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/24/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation

extension NSDate {
    
    func stringFromDateWithStringFormat(format: String) -> String {
        var dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = format;
        
        return dateFormatter.stringFromDate(self);
    }
}