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
    
    func stringFromDateWithStringFormats(formats: [String]) -> String {
        var dateFormatter = NSDateFormatter();
        
        var calendar: NSCalendar = NSCalendar.currentCalendar();
        let comps = (NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitYear);
        
        var nowDate = NSDate();
        var appDate = self;
        
        let date1Components: NSDateComponents = calendar.components(comps, fromDate: appDate);
        let date2Components: NSDateComponents = calendar.components(comps, fromDate: nowDate);

        appDate = calendar.dateFromComponents(date1Components)!;
        nowDate = calendar.dateFromComponents(date2Components)!;

        var result: NSComparisonResult = appDate.compare(nowDate);
        
        let atLS = NSLocalizedString("AT", comment: "comment");

        var dateTimeString: String?;
        
        if (result == NSComparisonResult.OrderedSame) {
            dateFormatter.dateFormat = formats[0];
            let todayLS = NSLocalizedString("TODAY", comment: "comment");

            dateTimeString = "\(todayLS), \(atLS) \(dateFormatter.stringFromDate(self))";
        } else {
            dateFormatter.dateFormat = formats[1];
            var dateString: String = dateFormatter.stringFromDate(self);
            
            dateFormatter.dateFormat = formats[2];
            
            dateTimeString = "\(dateString) \(atLS) \(dateFormatter.stringFromDate(self))";
        }
        
        return dateTimeString!;
    }
}