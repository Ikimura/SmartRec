//
//  SRCommonRouteMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/14/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRCommonRouteMapViewController : SRCommonViewController, GMSMapViewDelegate {
    
    @IBOutlet var mapView: GMSMapView!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
    }
    
    //MARK: - Configure
    
    func setUpMap(targetCoordinate: CLLocationCoordinate2D) {
        
        let camera = GMSCameraPosition.cameraWithLatitude(targetCoordinate.latitude, longitude: targetCoordinate.longitude, zoom: 13)
        mapView.camera = camera;
        mapView.delegate = self;
    }
    
    func makeRoute(path: GMSPath, id: String, strokeWidth: CGFloat, colored color: UIColor) {
        
        var polyline = SRMapPolyline(path: path);
        polyline.strokeWidth = strokeWidth;
        polyline.strokeColor = color;
        polyline.tappable = true;
        polyline.map = mapView;
        polyline.routeID = id;
        
        self.zoomToMarkersWithPath(path);
    }
    
    //MARK: - nav bar behavior
    
    func toggle(sender: AnyObject) {
        navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true) //or animated: false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true;
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade;
    }
    
    //MARK: - private
    
    private func zoomToMarkersWithPath(path: GMSPath) {
        
        let coordinateBounds = GMSCoordinateBounds(path: path);
        let mapInsets = UIEdgeInsetsMake(110, 20, 60, 20);
        
        let camera = GMSCameraUpdate.fitBounds(coordinateBounds, withEdgeInsets: mapInsets);
        
        mapView.animateWithCameraUpdate(camera);
    }
    
    //MARK: - delegate
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        
    }
    
    func mapView(mapView: GMSMapView, didTapOverlay overlay:GMSOverlay) {
        
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        return false;
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.toggle(mapView);
    }
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView! {
        
        return UIView(frame: CGRectZero);
    }

}