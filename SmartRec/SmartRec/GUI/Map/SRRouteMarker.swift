//
//  SRRouteMarker.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//


class SRRouteMarker: GMSMarker {
    let videoPoint: SRVideoPlace;
    let routeID: String;

    init(videoPoint: SRVideoPlace, routeID: String) {
        self.videoPoint = videoPoint;
        self.routeID = routeID;
        
        super.init()
        
        position = videoPoint.coordinate;
        icon = UIImage(named: "");
        groundAnchor = CGPoint(x: 0.5, y: 1);
        appearAnimation = kGMSMarkerAnimationPop;
    }
}
