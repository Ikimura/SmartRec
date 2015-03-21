//
//  SRCoreDataAppointmentExtension.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/12/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import CoreData

extension SRCoreDataAppointment {

    class func markArrivedAppointmnetWithId(id: String) {
        
        var context = SRCoreDataContextProvider.mainManagedObjectContext();
        
        if var event: SRCoreDataAppointment? = SRCoreDataManager.sharedInstance.singleManagedObject("SRCoreDataAppointment", withUniqueField: id, inContext: context) as? SRCoreDataAppointment! {
            
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
    
    class func insertAppointment(appointment: SRAppointment) -> SRResult {
        
        var context = SRCoreDataContextProvider.mainManagedObjectContext();
        
        var appointmentEntity: SRCoreDataAppointment? = NSEntityDescription.insertNewObjectForEntityForName("SRCoreDataAppointment", inManagedObjectContext: context) as? SRCoreDataAppointment;
        
        var placeEntity: SRCoreDataPlace? = NSEntityDescription.insertNewObjectForEntityForName("SRCoreDataPlace", inManagedObjectContext: context) as? SRCoreDataPlace;
        
        if (appointmentEntity != nil && placeEntity != nil) {
            
            appointmentEntity?.fillAppointmentPropertiesWith(appointment);
            placeEntity?.fillPropertiesFromStruct(appointment.place);
            
            //add relashioships
            appointmentEntity!.place = placeEntity!;
            placeEntity!.addAppointment(appointmentEntity!);
            
            var error: NSError?;
            context.save(&error);
            
            if error != nil {
                
                return .Failure(error!);
            }
            
            return .Success(true);
        }
        
        return .Failure(NSError(domain: "SRCoreDataManagerInsertDomain", code: -57, userInfo: nil));
    }
    
}