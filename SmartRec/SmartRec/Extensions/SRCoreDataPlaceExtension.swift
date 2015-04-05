//
//  SRCoreDataPlaceExtensions.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/9/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

extension SRCoreDataPlace {
    
    func addAppointment(appointment: SRCoreDataAppointment) {
        
        var tempSet: NSMutableSet = NSMutableSet(set: appointments);
        tempSet.addObject(appointment);
        
        appointments = tempSet;
    }
    
    func fillPropertiesFromDetailsDectionary(result: NSDictionary) {
        
        self.formattedAddress = result["formatted_address"] as? String;
        
        self.formattedPhoneNumber = result["formatted_phone_number"] as? String;
        self.internalPhoneNumber = result["international_phone_number"] as? String;
        
        self.website = result["website"] as? String;
        
        var openingHours = result["opening_hours"] as? NSDictionary;
        
        if (openingHours != nil) {
            
            var weekdayArray = openingHours!["weekday_text"] as [String];
            var weekDayT: String = "";
            
            for day in weekdayArray {
                weekDayT = weekDayT + day + "\n";
            }
            
            self.weekdayText = weekDayT;
        }
    }
    
    func fillPropertiesFromDectionary(result: NSDictionary) {
        
        var placeId = result["place_id"] as? String!;
        var name = result["name"] as? String!;
        var reference = result["reference"] as? String!;
        
        if var iconURLString = result["icon"] as? String {
            
             self.iconURL = iconURLString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!;
        }
        
        var vicinity = result["vicinity"] as? String;
        var types = result["types"] as [String]!;
        self.types = "";
        for type in types {
            
            self.types += "\(type)";
        }
        
        var formattedAddress = result["formatted_address"] as? String;
        
        var lat: Double?;
        var lng: Double?;
        
        if let geometry = result["geometry"] as? NSDictionary {
            if let location = geometry["location"] as? NSDictionary {
                
                lat = location["lat"] as? Double!;
                lng = location["lng"] as? Double!;
            }
        }
        
        self.lat = lat!;
        self.lng = lng!;

        var photosRefs: [String] = [];
        
        if let photos = result["photos"] as? Array<NSDictionary> {
            
            for photo in photos {
                
                if let photoRef = photo["photo_reference"] as? String {
                    
                    self.photoReference = photoRef;
                    break;
                }
            }
        }
        
        self.name = name!;
        self.placeId = placeId!;
        self.reference = reference!;
        self.vicinity = vicinity;
        if (self.formattedAddress == nil) {
            
            self.formattedAddress = formattedAddress;
        }
    }
}