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
    
    private var scheduledAppointments: [String] = [];
    
    init() {
        
        dataSource.rebuildDataSet();
    }
    
    //MARK: - internal
    
    func scheduleLocationNotificationIfNeeded() {
        
//        var allSet: NSMutableSet = NSMutableSet(array: dataSource.dataSet!);
//        
//        var app:UIApplication = UIApplication.sharedApplication();
//        var alreadyScheduledSet: NSMutableSet = NSMutableSet(array: app.scheduledLocalNotifications);
//        
//        allSet.minusSet(alreadyScheduledSet);
//        var toScheduleSet: NSMutableSet = allSet.copy() as NSMutableSet;
//        
//        
//        allSet = NSMutableSet(array: dataSource.dataSet!);
//        
//        alreadyScheduledSet.minusSet(allSet);
//        var toDeleteSet: NSMutableSet = alreadyScheduledSet;

        for item in dataSource.dataSet! {
            
            if let appointment = item as? SRCoreDataAppointment {
                
//                if ( !contains(scheduledAppointments, appointment.id)) {
                
                    var locNotification = UILocalNotification();
                    locNotification.alertBody = "You have arrived to \(appointment.place.name)!";
                    locNotification.regionTriggersOnce = false;
                    locNotification.category = "APPOINTMENTS_REMINDER_CATEGORY";
                    locNotification.userInfo = ["uuid": appointment.id];
                
                    locNotification.region = CLCircularRegion(circularRegionWithCenter: CLLocationCoordinate2DMake(appointment.place.lat.doubleValue, appointment.place.lng.doubleValue), radius: kLocRadius, identifier: appointment.id);
                    
                    println(locNotification.region.identifier);
                    
                    UIApplication.sharedApplication().scheduleLocalNotification(locNotification);
                
//                    UIApplication.sharedApplication().ca
//                    scheduledAppointments.append(appointment.id);
//                }
            }
        }
    }

    //MARK: - SRDataSourceDelegate
    
    func dataSourceDidChangeDataSet(dataSource: SRDataSource) {
     
        println("dataSourceDidChangeDataSet");
        
        self.scheduleLocationNotificationIfNeeded();
    }
}