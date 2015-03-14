//
//  SRGoogleSearchServiceProtocol.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/14/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

protocol SRGoogleSearchServiceProtocol {
    
    func nearbySearchPlaces(lat: Double, lng: Double, radius: Int, types:[String], keyword: String?, name: String?, complitionBlock: (data: [SRGooglePlace]) -> Void, errorComplitionBlock: (error: NSError) -> Void);
    
    func placeDetails(placeId: String, complitionBlock: (data: NSDictionary?) -> Void, errorComplitionBlock: (error: NSError) -> Void);
 
    func placeTextSearch(textQeury: String, lat: Double?, lng: Double?, radius: Int?, types:[String]?, complitionBlock: (data: [SRGooglePlace]!) -> Void, errorComplitionBlock: (error: NSError) -> Void);
    
    func googleDirectionFrom(origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, mode: String, complitionBlock: (path: GMSPath, metrics: Dictionary<String, String>) -> Void, errorComplitionBlock: (error: NSError) -> Void);

}