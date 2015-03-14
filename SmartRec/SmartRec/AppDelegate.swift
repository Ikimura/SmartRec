//
//  AppDelegate.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    
    var coreDataManager: SRCoreDataManager!;
    var eventsTracker: SRAppointmentsTracker!;
    var locationManager: CLLocationManager!;
    
    private var currrentLocation: CLLocation?;
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //Appearnces
        UINavigationBar.appearance().shadowImage = UIImage();
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)

        UIApplication.sharedApplication().statusBarStyle = .LightContent;

        //sync defaults
        self.synchronizeUserDefaults();
        
        //register google service
        GMSServices.provideAPIKey(kGoogleMapsAPIKey);
        
        //init
        coreDataManager = SRCoreDataManager(storePath: kStorePathComponent);
        eventsTracker = SRAppointmentsTracker();
        
        //init location service
        locationManager = CLLocationManager();
        //TODO: kCLLocationAccuracyHundredMeterscon.epam.evnt.
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        //TODO: 100
        locationManager.distanceFilter = 1;
        locationManager.delegate = self;
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            
            locationManager.requestWhenInUseAuthorization();
        }

        return true;
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        println("applicationWillEnterForeground");
        //TODO: delete appointments
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        
        println("Received Local Notification:")
        if let region = notification.region as CLRegion! {
            
            println(region.identifier);
        }
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        var uuid: String? = nil;
        
        if let region = notification.region as CLRegion! {
            
            uuid = notification.userInfo!["uuid"] as? String
        }
        
        if (identifier == "MARK_ARRIVED" && uuid != nil) {

            SRCoreDataAppointment.markArrivedAppointmnetWithId(uuid!);
            
        } else if identifier == "SHOW_APPOINTMENT" {
            
            println("showAppointment action");
            NSNotificationCenter.defaultCenter().postNotificationName("SHOW_APPOINTMENT", object: nil, userInfo: ["uuid": uuid!]);
        }
        
        completionHandler();
    }
    
    //MARK: - internal
    
    func currentLocation() -> CLLocation {
        
        if (self.currrentLocation == nil) {
            
            //GRODNO
            return  CLLocation(latitude: 53.6884000, longitude: 23.8258000);
        }
        
        return self.currrentLocation!;
    }
    
    func startMonitoringLocation() {
        self.locationManager.startUpdatingLocation();
        //        locationManager.startMonitoringSignificantLocationChanges();
    }
    
    func stopMonitoringLocation() {
        self.locationManager.stopUpdatingLocation();
        //        locationManager.stopMonitoringSignificantLocationChanges();
    }

    //MARK: - private
    
    private func setupNotificationSettings() {
        // Specify the notification types.
        var notificationTypes: UIUserNotificationType = .Alert | .Sound;
        
        var markArrivedAction = UIMutableUserNotificationAction();
        markArrivedAction.identifier = "MARK_ARRIVED";
        markArrivedAction.title = "Mark arrived";
        markArrivedAction.activationMode = .Background;
        markArrivedAction.destructive = false;
        markArrivedAction.authenticationRequired = true;
        
        var showAction = UIMutableUserNotificationAction();
        showAction.identifier = "SHOW_APPOINTMENT";
        showAction.title = "Show";
        showAction.activationMode = .Foreground;
        showAction.destructive = false;
        showAction.authenticationRequired = true;
        
        let actionsArray = NSArray(objects: markArrivedAction, showAction);
        let actionsArrayMinimal = NSArray(objects: markArrivedAction, showAction);
        
        // Specify the category related to the above actions.
        var appointmentsReminderCategory = UIMutableUserNotificationCategory()
        appointmentsReminderCategory.identifier = "APPOINTMENTS_REMINDER_CATEGORY";
        appointmentsReminderCategory.setActions(actionsArray, forContext: UIUserNotificationActionContext.Default)
        appointmentsReminderCategory.setActions(actionsArrayMinimal, forContext: UIUserNotificationActionContext.Minimal)

        let categoriesForSettings = NSSet(objects: appointmentsReminderCategory);
        
        let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings)

        UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
    }
    
    private func synchronizeUserDefaults() {
        
        if let settingsBundle = NSBundle.mainBundle().pathForResource("Settings", ofType: "bundle") {
            
            let settings = NSDictionary(contentsOfFile: settingsBundle.stringByAppendingPathComponent("Root.plist"));
            let preferences = settings?.objectForKey("PreferenceSpecifiers") as NSArray;
            
            let defaultsToRegister = NSMutableDictionary(capacity: preferences.count);
            let defaults = NSUserDefaults.standardUserDefaults();
            
            defaults.registerDefaults(defaultsToRegister);
            
            defaults.synchronize();
        }
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            //start update location
            self.startMonitoringLocation();

            let notificationSettings: UIUserNotificationSettings! = UIApplication.sharedApplication().currentUserNotificationSettings();
            
            if (notificationSettings.types == UIUserNotificationType.None){
                //setup notifications
                self.setupNotificationSettings();
            }
            
            //schedule notifications
            eventsTracker.scheduleLocationNotificationIfNeeded();
            
            NSLog("\(status)");
        default:
            NSLog("\(status)");
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        currrentLocation = locations[0] as? CLLocation;
        //post notification
        
        NSNotificationCenter.defaultCenter().postNotificationName(kLocationTitleNotification, object: nil, userInfo: ["location": locations[0] as CLLocation]);
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("\(error)");
    }

}

