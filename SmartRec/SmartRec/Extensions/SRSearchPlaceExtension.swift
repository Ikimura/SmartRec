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
            
            var placeId = result["place_id"] as? String;
            var name = result["name"] as? String;
            var reference = result["reference"] as? String;
            var iconURL: NSURL?;
            
            if var iconURLString = result["icon"] as? String {
                
                iconURLString = iconURLString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!;
                iconURL = NSURL(string: iconURLString);
            }
            
            var vicinity = result["vicinity"] as? String;
            var types = result["types"] as? [String];
            var formattedAddress = result["formatted_address"] as? String;
            
            var lat: Double?;
            var lng: Double?;
            
            if let geometry = result["geometry"] as? NSDictionary {
                if let location = geometry["location"] as? NSDictionary {
                    
                    lat = location["lat"] as? Double;
                    lng = location["lng"] as? Double;
                }
            }
            
            var photosRefs: [String] = [];
            
            if let photos = result["photos"] as? Array<NSDictionary> {
                
                for photo in photos {
                    
                    if let photoRef = photo["photo_reference"] as? String {
                        
                        photosRefs.append(photoRef);
                    }
                }
            }
            
            var place: SRGooglePlace = SRGooglePlace(placeId: placeId!, reference: reference!, lng: lng!, lat: lat!, iconURL: iconURL, name: name, types: types, vicinity: vicinity, formattedAddress: formattedAddress, formattedPhoneNumber: nil, internalPhoneNumber: nil, distance: nil, photoReferences: photosRefs, website: nil);
            
            places.append(place);
        }
        
        return places;
    }
}