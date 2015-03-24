//
//  CLLocationExtensions.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/7/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

extension CLLocation {

    class func distanceBetweenLocation(firstLocation: CLLocationCoordinate2D, secondLocation: CLLocationCoordinate2D) -> CGFloat {
        
         let M_PI_180: CGFloat = CGFloat(M_PI / 180);

        let R: CGFloat = 6371; // Radius of the Earth in km
        let dLat: CGFloat = CGFloat(secondLocation.latitude - firstLocation.latitude) * M_PI_180;
        let dLon: CGFloat = CGFloat(secondLocation.longitude - firstLocation.longitude) * M_PI_180;
        
        var a: CGFloat = sin(dLat / 2.0) * sin(dLat / 2.0);
        a = a + cos(CGFloat(firstLocation.latitude) * M_PI_180) * cos(CGFloat(secondLocation.latitude) * M_PI_180) * sin(dLon / 2.0) * sin(dLon / 2.0);
        
        let c: CGFloat = 2 * atan2(sqrt(a), sqrt(1 - a));
        
        let distanse: CGFloat = R * c;
        //km
        return distanse;
    }
    
}