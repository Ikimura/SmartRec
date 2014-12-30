//
//  SRCoommonMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/24/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import CoreData

class SRCommonMapViewController: SRCommonViewController, GMSMapViewDelegate {
    @IBOutlet var googleMapView: GMSMapView!
    
    private lazy var mapInfoView: SRMarkerInfoView! = {
        if let infoView = UIView.viewFromNibName("SRMarkerInfoView") as? SRMarkerInfoView!  {
            return infoView;
        } else {
            return nil;
        }
    }();
    
    //MARK: - internal interface
    
    func setUpMapViewWith(location: CLLocation?) {
        if (location != nil) {
            googleMapView.camera = GMSCameraPosition(target: location!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        }
        
        googleMapView.delegate = self;
        googleMapView.mapType = kGMSTypeNormal;
        googleMapView.myLocationEnabled = true
    }
    
    func makePolylineForRoute(route: AnyObject){
        var gmsPaths: GMSMutablePath = GMSMutablePath();
        
        if var tempRoute = route as? SRRoute {
            tempRoute.routePoints.enumerateObjectsUsingBlock {[weak self] (element, index, stop) -> Void in
                if var blockSelf = self {
                    if let routePoint = element as? SRRoutePoint {
                        gmsPaths.addCoordinate(CLLocationCoordinate2D(latitude: routePoint.latitude.doubleValue, longitude: routePoint.longitude.doubleValue));
                    }
                }
            };
        }
        
        var polyline: GMSPolyline = GMSPolyline(path: gmsPaths);
        polyline.strokeColor = UIColor.blueColor();
        polyline.strokeWidth = 5;
        polyline.map = googleMapView;
    }
    
    func showGoogleMapMarker(marker: GMSMarker) {
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = googleMapView;
    }
    
    
    //MARK: - private interface
    
    
    
    //MARK: - GMSMapViewDelegate
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        return false;
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
    }
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView! {
        
        if let routeMarker = marker as? SRRouteMarker {
            let anchor = marker.position;
            
            mapInfoView.titleLabel.text = routeMarker.videoPoint.fileName;
            mapInfoView.subtitleLabel.text = routeMarker.videoPoint.date;
            
            if let photo = routeMarker.videoPoint.photo {
                mapInfoView.imageView.image = photo;
            }
        }
        
        return mapInfoView;
    }
    
}