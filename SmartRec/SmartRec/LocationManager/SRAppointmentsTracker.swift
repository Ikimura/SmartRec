//
//  SRAppointmentsTracker.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/11/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRAppointmentsTracker : SRDataSourceDelegate {
    
    private lazy var dataSource: SRAppointmentsTrackerDataSource = {
        var temp = SRAppointmentsTrackerDataSource();
        temp.delegate = self;
        
        return temp;
    }();
    
    private var application: UIApplication = UIApplication.sharedApplication();
    private var scheduledAppointments: [String] = [];
    
    init() {
        
        dataSource.rebuildDataSet();
    }
    
    //MARK: - internal
    
    func rescheduleNotifications(){
        
        dataSource.rebuildDataSet();
        self.scheduleLocationNotificationsIfNeeded();
    }
    
    func cancelLocationNotificationWith(uuidToCancel: String) {
        
        var app: UIApplication = UIApplication.sharedApplication();
        
        for oneEvent in app.scheduledLocalNotifications {
            
            var notification = oneEvent as UILocalNotification
            
            if let userInfoCurrent = notification.userInfo as? Dictionary<String,String> {
                
                let uid = userInfoCurrent["uuid"]! as String
                if (uid == uuidToCancel) {
                    //Cancelling local notificationw
                    app.cancelLocalNotification(notification)
                    break;
                }
            }
        }
    }
    
    func scheduleNewLocationNotification(#appointment: SRCoreDataAppointment) {
        
        var locNotification = UILocalNotification();
        locNotification.alertBody = "You have arrived to \(appointment.place.name)!";
        locNotification.regionTriggersOnce = false;
        locNotification.category = "APPOINTMENTS_REMINDER_CATEGORY";
        locNotification.userInfo = ["uuid": appointment.id];
        
        locNotification.region = CLCircularRegion(circularRegionWithCenter: CLLocationCoordinate2DMake(appointment.place.lat.doubleValue, appointment.place.lng.doubleValue), radius: kLocRadius, identifier: appointment.id);
        
        application.scheduleLocalNotification(locNotification);
    }
    
    //MARK: - Private
    
    private func scheduleLocationNotificationsIfNeeded() {
        
        var newNotifications: NSMutableSet = NSMutableSet();
        for item in dataSource.dataSet! {
            
            if let appointment = item as? SRCoreDataAppointment {
                
                var locNotification = UILocalNotification();
                locNotification.alertBody = "You have arrived to \(appointment.place.name)!";
                locNotification.regionTriggersOnce = false;
                locNotification.category = "APPOINTMENTS_REMINDER_CATEGORY";
                locNotification.userInfo = ["uuid": appointment.id];
                
                locNotification.region = CLCircularRegion(circularRegionWithCenter: CLLocationCoordinate2DMake(appointment.place.lat.doubleValue, appointment.place.lng.doubleValue), radius: kLocRadius, identifier: appointment.id);
                
                println(locNotification.region.identifier);
                newNotifications.addObject(locNotification);
            }
        }
        
        var alreadyScheduledSet: NSMutableSet = NSMutableSet(array: application.scheduledLocalNotifications);
        
        //old notifications
        alreadyScheduledSet.minusSet(newNotifications);
        //cancell notifications
        for oldNotification in alreadyScheduledSet {
            application.cancelLocalNotification(oldNotification as UILocalNotification);
        }
        //detect unscheduled notifications
        newNotifications.minusSet(NSSet(array: application.scheduledLocalNotifications));
        //schedule notification
        for toScheduleNotification in newNotifications {
            application.scheduleLocalNotification(toScheduleNotification as UILocalNotification);
        }
    }

    //MARK: - SRDataSourceDelegate
    
    func dataSourceDidChangeDataSet(dataSource: SRDataSource) {
     
        println("dataSourceDidChangeDataSet");
    }
    
    func dataSourceDidUpdate(#object:AnyObject, atIndexPath indexPath: NSIndexPath?) {
        
        if let appointment = object as? SRCoreDataAppointment {
            
            var scheduledNotifications = application.scheduledLocalNotifications;
            var filteredNotifications = scheduledNotifications.filter( { (obj: AnyObject) -> Bool in
                let notif = obj as? UILocalNotification;
                return (notif?.userInfo?["uuid"] as String) == appointment.id;
            });
            
            if (appointment.locationTrack.boolValue && filteredNotifications.count == 0) {
                
                self.scheduleNewLocationNotification(appointment: appointment);
                
            } else if (!appointment.locationTrack.boolValue && filteredNotifications.count == 1) {
                
                self.cancelLocationNotificationWith(appointment.id);
            }
        }
    }
    
    func dataSourceDidDelete(#object:AnyObject, atIndexPath indexPath: NSIndexPath?) {
        
        if let deletedAppointment = object as? SRCoreDataAppointment {
            
            if (deletedAppointment.locationTrack.boolValue) {
                
                self.cancelLocationNotificationWith(deletedAppointment.id);
            }
        }
    }
    
    func dataSourceDidInsert(#object:AnyObject, atIndexPath indexPath: NSIndexPath?) {
        
        if let newAppointment = object as? SRCoreDataAppointment {
            
            if (newAppointment.locationTrack.boolValue) {
                
                self.scheduleNewLocationNotification(appointment: newAppointment);
            }
        }
    }
}