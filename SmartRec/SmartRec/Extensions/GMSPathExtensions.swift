//
//  GMSPathExtensions.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/8/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

extension GMSPath {
    
    class func parsePathsFromResponse(results: Array<NSDictionary>) -> (path: GMSPath, metrics: Dictionary<String, String>) {
        
        println("results = \(results.count)")
        
        var path: GMSPath?;
        
        let route = results[0];
        var id = route["summary"] as? String;
        var legs = route["legs"] as? Array<NSDictionary>;
            
        var firstLeg = legs![0];
        var distanceDict = firstLeg["distance"] as? NSDictionary;
        var durationDict = firstLeg["duration"] as? NSDictionary;
        
        var distString = distanceDict!["text"] as? String;
        var durString = durationDict!["text"] as? String;
        
        var metrics: Dictionary<String, String> = [
            "distance": distString!,
            "duration": durString!,
            "id": id!
        ];
        
        var polyline = route["overview_polyline"] as? NSDictionary;
        var overview_route = polyline!["points"] as? String;
        
        path = GMSPath(fromEncodedPath: overview_route!);
        
        return (path!, metrics);
    }
}
