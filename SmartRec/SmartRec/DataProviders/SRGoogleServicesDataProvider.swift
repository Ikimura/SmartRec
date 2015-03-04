//
//  SRGoogleGeocodingDataProvider.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/30/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation

enum SRResponseStatus: String {
    case OK = "OK";
    case ZERO_RESULTS = "ZERO_RESULTS";
    case OVER_QUERY_LIMIT = "OVER_QUERY_LIMIT";
    case REQUEST_DENIED = "REQUEST_DENIED";
    case INVALID_REQUEST = "INVALID_REQUEST";
    case UNKNOWN_ERROR = "UNKNOWN_ERROR";
    case NOT_FOUND = "NOT_FOUND";
}

//API Example
//https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=API_KEY
//https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=53.7034993390131,23.8192470413981&radius;=3000&types;=cafe|food&key;=API_KEY
//https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJN1t_tDeuEmsRUsoyG83frY4&key;=AddYourOwnKeyHere

class SRGoogleServicesDataProvider: SRGoogleGeocodingServiceProtocol, SRGoogleSearchServiceProtocol {

    //MARK: - SRGoogleGeocodingServiceProtocol
    func geocoding(lat: Double, lng: Double, complitionBlock: (data: AnyObject!) -> Void ) {
        
        var urlString = "\(kGoogleGeocodingAPIURL)latlng=\(lat),\(lng)&key=\(kGoogleServicesAPIKey)";
        println("Debug: \(urlString)");
        
        var requesOperationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager();
        let serializer = AFJSONResponseSerializer();
        requesOperationManager.responseSerializer = serializer;
        
        requesOperationManager.GET(urlString, parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            
            complitionBlock(data: responseObject);
            
        }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            println("Error: \(error)");
        }
    }
    
    func nearbySearchPlaces(lat: Double, lng: Double, radius: Int, types:[String], keyword: String?, name: String?, complitionBlock: (data: [SRGooglePlace]) -> Void, errorComplitionBlock: (error: NSError) -> Void) {
    
        var urlString = "\(kGoogleNearbySearchAPIURL)location=\(lat),\(lng)&radius=\(radius)&types=";
        
        for type in types {
            urlString += type + "|";
        }
        
        if (keyword != nil) {
            urlString += "&keyword=\(keyword!)";
        }
        
        urlString += "&key=\(kGooglePlaceAPIKey)";
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!

        println("Debug: \(urlString)");
        
        var requesOperationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager();
        let serializer = AFJSONResponseSerializer();
        requesOperationManager.responseSerializer = serializer;
        
        requesOperationManager.GET(urlString, parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            
            var status = responseObject["status"] as? String;
            var responsStatus: SRResponseStatus = SRResponseStatus(rawValue: status!)!;
            
            var places: [SRGooglePlace]?;

            switch (responsStatus) {
            case .OK:
                if var results = responseObject["results"] as? Array<NSDictionary> {
                    places = SRGooglePlace.fillPropertiesFromNearbySearchDectionary(results);
                }
            case .ZERO_RESULTS:
                places = [];
            case .INVALID_REQUEST:
                fallthrough;
            case .REQUEST_DENIED:
                fallthrough;
            case .OVER_QUERY_LIMIT:
                places = [];
                if let errorMessage = responseObject["error_message"] as? String {
                    println(errorMessage);
                }
            default:
                break;
            }
            
            complitionBlock(data: places!);
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                
                println("Error: \(error)");
                errorComplitionBlock(error: error);
        }
    }
    
    func placeTextSearch(textQeury: String, lat: Double?, lng: Double?, radius: Int?, types:[String]?, complitionBlock: (data: [SRGooglePlace]!) -> Void, errorComplitionBlock: (error: NSError) -> Void) {
        
        let formattedText = textQeury.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding);
        
        var urlString = "\(kGoogleTextSearchAPIURL)query=\(formattedText!)&sensor=true";
        
        if (lat != nil && lng != nil) {
            
            urlString += "&location=\(lat!),\(lng!)";
        }
        
        if (types != nil && types?.count != 0) {
            
            urlString += "&types=";
            
            for type in types! {
                urlString += type + "|";
            }
        }
        
        if (radius != nil) {
            
            urlString += "&radius=\(radius!)";
        }
        
        urlString += "&key=\(kGooglePlaceAPIKey)";
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;
        
        println("Debug: \(urlString)");
        
        var requesOperationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager();
        let serializer = AFJSONResponseSerializer();
        requesOperationManager.responseSerializer = serializer;
        
        requesOperationManager.GET(urlString, parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            
            var status = responseObject["status"] as? String;
            var responsStatus: SRResponseStatus = SRResponseStatus(rawValue: status!)!;
            
            var places: [SRGooglePlace]?;
            
            switch (responsStatus) {
            case .OK:
                if var results = responseObject["results"] as? Array<NSDictionary> {
                    places = SRGooglePlace.fillPropertiesFromNearbySearchDectionary(results);
                }
            case .ZERO_RESULTS:
                places = [];
            case .INVALID_REQUEST:
                fallthrough;
            case .REQUEST_DENIED:
                fallthrough;
            case .OVER_QUERY_LIMIT:
                places = [];
                if let errorMessage = responseObject["error_message"] as? String {
                    println(errorMessage);
                }
            default:
                break;
            }
            
            complitionBlock(data: places!);
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                
                println("Error: \(error)");
                errorComplitionBlock(error: error);
        }
    }

    
    func placeDetails(placeId: String, complitionBlock: (data: NSDictionary?) -> Void, errorComplitionBlock: (error: NSError) -> Void) {
        
        var urlString = "\(kGooglePlaceDetailsAPIURL)plcaeid=\(placeId)&key;=\(kGooglePlaceAPIKey)";
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;

        println("Debug: \(urlString)");
        
        var requesOperationManager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager();
        let serializer = AFJSONResponseSerializer();
        requesOperationManager.responseSerializer = serializer;
        
        requesOperationManager.GET(urlString, parameters: nil, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in

            var status = responseObject["status"] as? String;
            var responsStatus: SRResponseStatus = SRResponseStatus(rawValue: status!)!;
            
            var result = responseObject["result"] as? NSDictionary;
                        
            switch (responsStatus) {
            case .OK:
                println("OK");
            case .INVALID_REQUEST:
                fallthrough
            case .REQUEST_DENIED:
                fallthrough
            case .OVER_QUERY_LIMIT:
                fallthrough
            case .ZERO_RESULTS:
                fallthrough
            case .UNKNOWN_ERROR:
                fallthrough
            case .NOT_FOUND:
                if let errorMessage = responseObject["error_message"] as? String {
                    println(errorMessage);
                }
            default:
                break;
            }
            
            complitionBlock(data: result);
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in

                println("Error: \(error)");
                errorComplitionBlock(error: error);
        }
    }

}
