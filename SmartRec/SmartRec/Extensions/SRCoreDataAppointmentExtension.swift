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
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;

        if var event: SRCoreDataAppointment? = appDelegate.coreDataManager.checkForExistingEntity("SRCoreDataAppointment", withId: id, inContext: appDelegate.coreDataManager.mainObjectContext) as? SRCoreDataAppointment {
            
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
}