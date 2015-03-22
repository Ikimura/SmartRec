//
//  SRCoreDataPlaceExtensions.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/9/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

extension SRCoreDataPlace {
    
    func addAppointment(appointment: SRCoreDataAppointment) {
        
        var tempSet: NSMutableSet = NSMutableSet(set: appointments);
        tempSet.addObject(appointment);
        
        appointments = tempSet;
    }
    
    func fillPropertiesFromStruct(placeStruct: SRGooglePlace) {
        
        self.reference = placeStruct.reference;
        self.placeId = placeStruct.placeId;
        self.name = placeStruct.name!;
        self.lat = NSNumber(double: placeStruct.lat);
        self.lng = NSNumber(double: placeStruct.lng);
        self.iconURL = placeStruct.iconURL!.absoluteString!;
        
        if (placeStruct.photoReferences?.count != 0) {
            
            self.photoReference = placeStruct.photoReferences![0];
        }
        
        if (placeStruct.vicinity != nil) {
            
            self.vicinity = placeStruct.vicinity!;
        }
        
        self.formattedAddress = placeStruct.formattedAddress!;
        
        if (placeStruct.formattedPhoneNumber != nil) {
            self.formattedPhoneNumber = placeStruct.formattedPhoneNumber!;
        }
        
        if (placeStruct.internalPhoneNumber != nil) {
            self.internalPhoneNumber = placeStruct.internalPhoneNumber!;
        }
        
        if (placeStruct.distance != nil) {
            self.distance = placeStruct.distance!;
        }
        
        if (placeStruct.website != nil) {
            self.website = placeStruct.website!;
        }
        
        if (placeStruct.weekDayText != nil) {
            self.weekdayText = placeStruct.weekDayText!;
        }
        
//            if (appintmentData.place.zipCity != nil) {
//                placeEntity!.zipCity = appintmentData.place.zipCity!;
//            }
    }
    
}