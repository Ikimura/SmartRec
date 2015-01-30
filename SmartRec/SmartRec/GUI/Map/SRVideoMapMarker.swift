//
//  SRRouteMarker.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//


class SRVideoMapMarker: SRBaseMapMarker {
    let videoPoint: SRVideoPlace;
    
    init(videoPoint: SRVideoPlace, routeID: String) {
        self.videoPoint = videoPoint;
        
        super.init(routeID: routeID);
        
        position = videoPoint.coordinate;
        icon = UIImage(named: "");
        groundAnchor = CGPoint(x: 0.5, y: 1);
        appearAnimation = kGMSMarkerAnimationPop;
    }
}
