//
//  GMSMapExtension.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 5/10/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import MapKit

extension GMSMapView {
    
    func visibleRegionRadius() -> Double {
        
        let region = self.projection.visibleRegion()
        let verticalDistance = GMSGeometryDistance(region.farLeft, region.nearLeft)
        let horizontalDistance = GMSGeometryDistance(region.farLeft, region.farRight)
        
        return max(horizontalDistance, verticalDistance) * 0.5;
    }
    
    class func translateCoordinate(coordinate: CLLocationCoordinate2D, metersLat: Double, metersLong: Double) -> (CLLocationCoordinate2D) {
        var tempCoord = coordinate
        
        let tempRegion = MKCoordinateRegionMakeWithDistance(coordinate, metersLat, metersLong)
        let tempSpan = tempRegion.span
        
        tempCoord.latitude = coordinate.latitude + tempSpan.latitudeDelta
        tempCoord.longitude = coordinate.longitude + tempSpan.longitudeDelta
        
        return tempCoord
    }
    
    func setRadius(radius: Double, withСoordinate coordinate: CLLocationCoordinate2D) {
        
        let range = GMSMapView.translateCoordinate(coordinate, metersLat: radius * 2, metersLong: radius * 2)
        
        let bounds = GMSCoordinateBounds(coordinate: coordinate, coordinate: range)
        
        let update = GMSCameraUpdate.fitBounds(bounds, withPadding: 5.0)// padding set to 5.0
        
        self.moveCamera(update)
        
        self.animateToLocation(coordinate) // animate to center
    }
}