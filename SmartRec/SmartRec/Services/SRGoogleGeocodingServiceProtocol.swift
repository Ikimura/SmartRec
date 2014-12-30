//
//  SRGoogleGeocodingServiceProtocol.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/30/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation

protocol SRGoogleGeocodingServiceProtocol {
    
    func geocoding(lat: Double, lng: Double, complitionBlock: (data: AnyObject!) -> Void );
    
}