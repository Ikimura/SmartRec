//
//  SRLocationManager.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/29/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreLocation

protocol SRLocationManagerDelegate {
    func srlocationManager(manager: SRLocationManager!, didUpdateLocations locations: [AnyObject]!);
}

class SRLocationManager : NSObject, CLLocationManagerDelegate {
    class var sharedInstance : SRLocationManager {
        struct Static {
            static let instance : SRLocationManager = SRLocationManager();
        }
        return Static.instance;
    }
    
    private var locationManager: CLLocationManager;
    var delegate: SRLocationManagerDelegate?;
    
    override init() {
        locationManager = CLLocationManager();
        
        super.init();
        //TODO: kCLLocationAccuracyHundredMeters
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        //TODO: 50
        locationManager.distanceFilter = 1;
        locationManager.delegate = self;
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization();
        }
    }
    
    func startMonitoringLocation() {
        locationManager.startUpdatingLocation();
//        locationManager.startMonitoringSignificantLocationChanges();
    }
    
    func stopMonitoringLocation() {
        locationManager.stopUpdatingLocation();
//        locationManager.stopMonitoringSignificantLocationChanges();
    }
    
    //MARK - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse:
            NSLog("\(status)");
        default:
            NSLog("\(status)");
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        delegate?.srlocationManager(self, didUpdateLocations: locations);
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("\(error)");
    }
    
}