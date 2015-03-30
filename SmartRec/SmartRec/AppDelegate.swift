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
    
    var eventsTracker: SRAppointmentsTracker!;
    var GoogleServiceReachable: Reachability?;
    
    private(set) var isOfflineMode: Bool?;

    private var locationManager: CLLocationManager!;
    private var currrentLocation: CLLocation?;

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //Appearnces
        UINavigationBar.appearance().shadowImage = UIImage();
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)

        UIApplication.sharedApplication().statusBarStyle = .LightContent;

        self.setupGoogleServiceReachability();
        
        //sync defaults
        self.synchronizeUserDefaults();
        
        //register google service
        GMSServices.provideAPIKey(kGoogleMapsAPIKey);
        
        //init
        eventsTracker = SRAppointmentsTracker();
        SRCoreDataContextProvider.sharedInstance;
        
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
        
//        var req = NSFetchRequest(entityName: "SRCoreDataAppointment");
//        var context = SRCoreDataContextProvider.mainManagedObjectContext();
//        println((context.executeFetchRequest(req, error: nil)?.first as SRCoreDataAppointment)?.id);

        return true;
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        GoogleServiceReachable?.stopNotifier();
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        //schedule notifications
        eventsTracker.rescheduleNotifications();
        println("applicationWillEnterForeground");
        
        GoogleServiceReachable?.startNotifier();
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.startMonitoringLocation();
        
        isOfflineMode = !GoogleServiceReachable!.isReachable();
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.stopMonitoringLocation();
    }
    
    
    //MARK: - Reachability
    
    func setupGoogleServiceReachability() {
        
        GoogleServiceReachable = Reachability(hostName: "google.com");
        
        GoogleServiceReachable?.reachableBlock = { [weak self] (reach: Reachability!) -> Void in
            
            if let strongSelf = self {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    strongSelf.applicationDidSwitchToOnline();
//                    NSObject.cancelPreviousPerformRequestsWithTarget(strongSelf, selector: "applicationDidSwitchToOffline", object: nil);
//                    
//                    if (strongSelf.isOfflineMode) {
//                        
//                        NSObject.cancelPreviousPerformRequestsWithTarget(strongSelf, selector: "applicationDidSwitchToOnline", object: nil);
//                        
//                        NSObject.performSelector("applicationDidSwitchToOnline", withObject: nil, afterDelay: 4.0);
//                    }
                });
            }
        }
        
        GoogleServiceReachable?.unreachableBlock = { [weak self] (reach: Reachability!) -> Void in
            
            if let strongSelf = self {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    strongSelf.applicationDidSwitchToOffline();
//                    NSObject.cancelPreviousPerformRequestsWithTarget(strongSelf, selector: "applicationDidSwitchToOnline", object: nil);
//                    
//                    NSObject.cancelPreviousPerformRequestsWithTarget(strongSelf, selector: "applicationDidSwitchToOffline", object: nil);
                });
                
//                if (strongSelf.isOfflineMode!) {
//                
//                    NSObject.cancelPreviousPerformRequestsWithTarget(strongSelf, selector: "applicationDidSwitchToOnline", object: nil);
//                    
//                    NSObject.performSelector("applicationDidSwitchToOffline", withObject: nil, afterDelay: 5.0);
//                }
            }
        }

        GoogleServiceReachable?.startNotifier();
    }
    
    func applicationDidSwitchToOnline() {
        
        self.isOfflineMode = false;
    }
    
    func applicationDidSwitchToOffline() {
        
        self.isOfflineMode = true;
    }
    
    //MARK: - Notifications
    
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
        
        if (currrentLocation == nil) {
            //GRODNO
            if (locationManager.location != nil) {
                
                currrentLocation = locationManager.location!;
                
            } else {
                
                currrentLocation = CLLocation(latitude: 53.6884000, longitude: 23.8258000);
            }

        }
        
        return currrentLocation!;
    }
    
    func startMonitoringLocation() {
        locationManager.startUpdatingLocation();
//                locationManager.startMonitoringSignificantLocationChanges();
    }
    
    func stopMonitoringLocation() {
        locationManager.stopUpdatingLocation();
        //        locationManager.stopMonitoringSignificantLocationChanges();
    }

    //MARK: - private
    
    private func setupNotificationSettings() {
        // Specify the notification types.
        var notificationTypes: UIUserNotificationType = .Alert | .Sound;
        
        var markArrivedAction = UIMutableUserNotificationAction();
        markArrivedAction.identifier = "MARK_ARRIVED";
        markArrivedAction.title = NSLocalizedString("arrived_btn_title", comment:"");
        markArrivedAction.activationMode = .Background;
        markArrivedAction.destructive = false;
        markArrivedAction.authenticationRequired = true;
        
        var showAction = UIMutableUserNotificationAction();
        showAction.identifier = "SHOW_APPOINTMENT";
        showAction.title = NSLocalizedString("notification_show_btn", comment:"");
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
            eventsTracker.rescheduleNotifications();
            
            NSLog("\(status)");
        default:
            NSLog("\(status)");
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        currrentLocation = locations.last as? CLLocation;
        //post notification
        NSNotificationCenter.defaultCenter().postNotificationName(kLocationTitleNotification, object: nil, userInfo: ["location": currrentLocation!]);
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("\(error)");
    }

}

