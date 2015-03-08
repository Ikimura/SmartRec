//
//  GMSPathExtensions.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/8/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

extension GMSPath {
    
    class func parsePathsFromResponse(results: Array<NSDictionary>) -> (path: GMSPath, metric: (distance: String, duration: String)) {
        
        println("results = \(results.count)")
        
        var path: GMSPath?;
        var metric: (distance: String, duration: String)?;
        
        let route = results[0];
            
        var legs = route["legs"] as? Array<NSDictionary>;
            
        var firstLeg = legs![0];
        var distanceDict = firstLeg["distance"] as? NSDictionary;
        var durationDict = firstLeg["duration"] as? NSDictionary;
        
        var distString = distanceDict!["text"] as? String;
        var durString = durationDict!["text"] as? String;
        
        metric = (distance: distString!, duration: durString!);
        
        var polyline = route["overview_polyline"] as? NSDictionary;
        var overview_route = polyline!["points"] as? String;
        
        path = GMSPath(fromEncodedPath: overview_route!);
        
        return (path!, metric!);
    }
}
