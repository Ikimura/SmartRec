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
    var lng: Double;
    var lat: Double;
    var iconURL: NSURL?;
    var name: String?;
    var types: [String]?;
    var vicinity: String?;
    var formatedAddres: String?;
    var formattedPhoneNumber: String?;
    var distance: Double?;
    var photoReferences: [String]?;
    var website: String?;
    
    mutating func fillDetailsPropertiesForPlace(results: NSDictionary) {
        
        formatedAddres = results["formatted_address"] as? String;
        
        formattedPhoneNumber = results["formatted_phone_number"] as? String;
        
        website = results["website"] as? String;
    }
    
    mutating func addDistance(newDistance: Double) {
        
        distance = newDistance;
    }
}

