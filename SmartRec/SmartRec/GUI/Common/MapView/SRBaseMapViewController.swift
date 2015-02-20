//
//  SRBaseMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/16/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRBaseMapViewController: SRCommonViewController, SRBaseMapViewDataSource, SRBaseMapViewDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    //MARK: - SRBaseMapViewDataSource
    
    func initialLocation() -> CLLocationCoordinate2D {
        return SRLocationManager.sharedInstance.currentLocation()!.coordinate;
    }
    
    func numberOfMarkers() -> Int {
        return 0;
    }
    
    func titleForMarkerAtIndex(index: Int) -> String? {
        return nil;
    }
    
    func identifierForMarkerAtIndex(index: Int) -> AnyObject? {
        return NSNumber(integer: index);
    }
    
    func locationForMarkerAtIndex(index: Int) -> CLLocationCoordinate2D? {
        return nil;
    }
    
    func iconForMarkerAtIndex(index: Int) -> UIImage? {
        return nil;
    }
    
    func verticalOffsetForCalloutView() -> CGFloat {
        return 0;
    }
    
    //MARK: - SRBaseMapViewDelegate
    
    func didTapMarker() -> Bool {
        return false;
    }
    
    func calloutAccessoryControlTappedByIdentifier(identifier: AnyObject) {
        
    }
    
    func didChangeCameraPosition(position: GMSCameraPosition, byGesture: Bool) {
        
    }

}