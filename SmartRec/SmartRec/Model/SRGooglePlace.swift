//
//  SRGooglePLace.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/14/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

struct SRGooglePlace {
    
    var placeId: String;
    var reference: String;
    var lng: Double;
    var lat: Double;
    var iconURL: NSURL?;
    var name: String?;
    var types: [String]?;
    var vicinity: String?;
    var formattedAddress: String?;
    var formattedPhoneNumber: String?;
    var internalPhoneNumber: String?;
    var distance: Float?;
    var photoReferences: [String]?;
    var website: String?;
    var weekDayText: String?;
//    var zipCity: String?;

    
    mutating func fillDetailsPropertiesForPlace(results: NSDictionary) {
        
        formattedAddress = results["formatted_address"] as? String;
        
        formattedPhoneNumber = results["formatted_phone_number"] as? String;
        internalPhoneNumber = results["international_phone_number"] as? String;
        
        website = results["website"] as? String;
        
        var openingHours = results["opening_hours"] as? NSDictionary;
        
        if (openingHours != nil) {
            
            var weekdayArray = openingHours!["weekday_text"] as [String];
            var weekDayT: String = "";
            
            for day in weekdayArray {
                weekDayT = weekDayT + day + "\n";
            }
            
            weekDayText = weekDayT;
        }
    }
    
    mutating func addDistance(newDistance: Float) {
        
        distance = newDistance;
    }
}

