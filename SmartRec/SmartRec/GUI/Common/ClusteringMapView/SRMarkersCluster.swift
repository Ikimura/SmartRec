//
//  SRMarkersCluster.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/17/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRMarkersCluster: NSObject {

    var point: Int?;
    var isShowing: Bool = false;
    var clusterLocation: CLLocationCoordinate2D?;
    var indexesForMarkers: [Int] = [];
    
}
