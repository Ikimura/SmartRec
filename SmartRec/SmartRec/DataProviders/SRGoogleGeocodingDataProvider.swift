//
//  SRGoogleGeocodingDataProvider.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/30/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation

//API Example
//https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=API_KEY

class SRGoogleGeocodingDataProvider: SRGoogleGeocodingServiceProtocol {

    //MARK: - SRGoogleGeocodingServiceProtocol
    func geocoding(lat: Double, lng: Double, complitionBlock: (data: AnyObject!) -> Void ) {
        
        let  manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager();
        let serializer = AFJSONResponseSerializer();
        manager.responseSerializer = serializer;
        
        var urlString = "\(kGoogleGeocodingAPIURL)latlng=\(lat),\(lng)&key=\(kGoogleGeocodingAPIKey)";
        println("Debug: \(urlString)");
        
        manager.GET(urlString, parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            println("JSON: \(responseObject)");
            complitionBlock(data: responseObject);
        }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            println("Error: \(error)");
        }
    }

}
