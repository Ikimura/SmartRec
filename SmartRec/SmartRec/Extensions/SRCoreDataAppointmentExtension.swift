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
            
            event!.completed = true;
            
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
        
        self.locationTrack = appintmentData.locationTrack;
        let fireDate = NSDate(timeIntervalSince1970: appintmentData.dateInSeconds);
        self.fireDate = fireDate.timeIntervalSince1970;
        self.sortDate = NSCalendar.currentCalendar().startOfDayForDate(fireDate).timeIntervalSince1970;
        self.note = appintmentData.description;
        println("\(appintmentData.id)");
        self.id = "\(appintmentData.id)";
        self.completed = false;
    }
    
    class func insertAppointment(appointment: SRAppointment) -> SRResult {
        
        var context = SRCoreDataContextProvider.mainManagedObjectContext();
        
        var appointmentEntity: SRCoreDataAppointment? = NSEntityDescription.insertNewObjectForEntityForName("SRCoreDataAppointment", inManagedObjectContext: context) as? SRCoreDataAppointment;
        
        var placeEntity: SRCoreDataPlace = SRCoreDataManager.sharedInstance.singleManagedObject("SRCoreDataPlace", withUniqueField: appointment.place.placeId, inContext: context) as SRCoreDataPlace;
        
        if (appointmentEntity != nil) {
            
            appointmentEntity?.fillAppointmentPropertiesWith(appointment);
            
            //add relashioships
            appointmentEntity!.place = placeEntity;
            placeEntity.addAppointment(appointmentEntity!);
            
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