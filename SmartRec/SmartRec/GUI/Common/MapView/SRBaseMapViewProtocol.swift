//
//  SRBaseMapViewProtocol.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/14/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

protocol SRBaseMapViewDataSource {
    
    func initialLocation() -> CLLocationCoordinate2D;
    
    func numberOfMarkers() -> Int;
    func titleForMarkerAtIndex(index: Int) -> String?;
    func identifierForMarkerAtIndex(index: Int) -> AnyObject?;
    func locationForMarkerAtIndex(index: Int) -> CLLocationCoordinate2D?;
    func iconForMarkerAtIndex(index: Int) -> UIImage?;
    func verticalOffsetForCalloutView() -> CGFloat;
}

protocol SRBaseMapViewDelegate {
    
    func didTapMarker() -> Bool;
    func calloutAccessoryControlTappedByIdentifier(identifier: AnyObject);
    
    func didChangeCameraPosition(mapView: GMSMapView, position: GMSCameraPosition, byGesture: Bool);
}

protocol SRBaseMapViewProtocol {
    func setCameraCoordinate(coordinate: CLLocationCoordinate2D);
    func reloadMarkersList();
}