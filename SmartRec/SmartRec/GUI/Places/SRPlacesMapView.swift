//
//  PlacesMapView.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/25/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRPlacesMapView: SRClusteringMapView {
    
    override func reloadMarkersList() {
        super.reloadMarkersList();
        
        var marker: GMSMarker = GMSMarker();
        marker.title = "You";
        marker.position = dataSource!.initialLocation();
        marker.map = googleMapView;
        marker.icon = UIImage(named: "you_here");
    }
}