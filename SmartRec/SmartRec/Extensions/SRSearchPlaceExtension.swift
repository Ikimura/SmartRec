//
//  SRNearbySearchExtension.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/14/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

extension SRGooglePlace {
    
    static func fillPropertiesFromNearbySearchDectionary(results: Array<NSDictionary>) -> [SRGooglePlace] {
        
        println("results = \(results.count)")
        
        var places: [SRGooglePlace] = [];
        
        for result in results{
            
            var placeId = result["place_id"] as String;
            var name = result["name"] as? String;
            var iconURLString = result["icon"] as String;
            iconURLString = iconURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;
            var vicinity = result["vicinity"] as? String;
            var types: [String] = result["types"] as [String];
            var formattedAddress = result["formatted_address"] as? String;
            
            var lat: Double?;
            var lng: Double?;
            
            if let geometry = result["geometry"] as? NSDictionary {
                if let location = geometry["location"] as? NSDictionary {
                    
                    lat = location["lat"] as? Double;
                    lng = location["lng"] as? Double;
                }
            }
            
            var place: SRGooglePlace = SRGooglePlace(placeId: placeId, lng: lng!, lat: lat!, iconURL: NSURL(string: iconURLString), name: name, types: types, vicinity: vicinity, formatedAddres: formattedAddress, formattedPhoneNumber: nil, distance: nil);
            
            places.append(place);
        }
        
        return places;
    }
}