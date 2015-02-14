//
//  SRGoogleSearchServiceProtocol.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/14/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

protocol SRGoogleSearchServiceProtocol {
    
    func nearbySearchPlaces(lat: Double, lng: Double, radius: Int, types:[String], keyword: String?, name: String?, complitionBlock: (data: [SRGooglePlace]) -> Void );
    
    func placeDetails(placeId: String, complitionBlock: (data: NSDictionary?) -> Void );
    
}