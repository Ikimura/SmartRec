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

public class SRLocationManager : NSObject, CLLocationManagerDelegate {
    public class var sharedInstance : SRLocationManager {
        struct Static {
            static let instance : SRLocationManager = SRLocationManager();
        }
        return Static.instance;
    }
    
    var delegate: SRLocationManagerDelegate?;
    
    private var locationManager: CLLocationManager;

    public override init() {
        locationManager = CLLocationManager();
        
        super.init();
        //TODO: kCLLocationAccuracyHundredMeterscon.epam.evnt.
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        //TODO: 50
        locationManager.distanceFilter = 1;
        locationManager.delegate = self;
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization();
        }
    }
    
    //MARK: - public interface
    
    public func startMonitoringLocation() {
        self.locationManager.startUpdatingLocation();
//        locationManager.startMonitoringSignificantLocationChanges();
    }
    
    public func stopMonitoringLocation() {
        self.locationManager.stopUpdatingLocation();
//        locationManager.stopMonitoringSignificantLocationChanges();
    }
    
    //MARK: - CLLocationManagerDelegate
    
    public func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse:
            NSLog("\(status)");
        default:
            NSLog("\(status)");
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        delegate?.srlocationManager(self, didUpdateLocations: locations);
    }
  
    public func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    public func locationManagerDidResumeLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    public func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("\(error)");
    }
    
}