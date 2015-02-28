//
//  SRLocationManager.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/29/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreLocation

public class SRLocationManager : NSObject, CLLocationManagerDelegate {
    public class var sharedInstance : SRLocationManager {
        struct Static {
            static let instance : SRLocationManager = SRLocationManager();
        }
        return Static.instance;
    }
        
    private var locationManager: CLLocationManager!;
    private var currrentLocation: CLLocation?;

    public override init() {
        super.init();
        
        locationManager = CLLocationManager();

        //TODO: kCLLocationAccuracyHundredMeterscon.epam.evnt.
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        //TODO: 100
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
    
    public func currentLocation() -> CLLocation? {

        if (currrentLocation == nil) {
            return  CLLocation(latitude: 53.6884000, longitude: 23.8258000);
        }
        
        return currrentLocation;
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
        currrentLocation = locations[0] as? CLLocation;
        //post notification
        
        NSNotificationCenter.defaultCenter().postNotificationName(kLocationTitleNotification, object: nil, userInfo: ["location": locations[0] as CLLocation]);
    }
  
    public func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    public func locationManagerDidResumeLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    public func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("\(error)");
    }
    
}