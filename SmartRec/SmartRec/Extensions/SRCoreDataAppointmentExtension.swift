//
//  SRCoreDataAppointmentExtension.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/12/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

extension SRCoreDataAppointment {

    class func markArrivedAppointmnetWithId(id: String) {
        
        var context = SRCoreDataContextProvider.mainManagedObjectContext();
        
        if var event: SRCoreDataAppointment? = SRCoreDataManager.sharedInstance.singleManagedObject("SRCoreDataAppointment", withUniqueField: id, inContext: context) as? SRCoreDataAppointment {
            
            event!.completed = NSNumber(bool: true);
            
            var error: NSError?;
            event!.managedObjectContext?.save(&error);
            
            if (error != nil) {
                
                println("Can't save context after update");
                
            } else {
                
                println("OK!");
            }
        }
    }
    
    func fillAppointmentPropertiesWith(appintmentData: SRAppointment) {
            
        if (appintmentData.calendarId != nil) {
            self.calendarId = appintmentData.calendarId!;
        }
        
        self.locationTrack = NSNumber(bool: appintmentData.locationTrack);
        let fireDate = NSDate(timeIntervalSince1970: appintmentData.dateInSeconds);
        self.fireDate = fireDate;
        self.sortDate = NSCalendar.currentCalendar().startOfDayForDate(fireDate);
        self.note = appintmentData.description;
        println("\(appintmentData.id)");
        self.id = "\(appintmentData.id)";
        self.completed = NSNumber(bool: false);
    }
}