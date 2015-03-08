//
//  SRAppointment.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/8/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

struct SRAppointment {

    var place: SRGooglePlace;
    var dateInSeconds: Double;
    var locationTrack: Bool;
    var description: String;
    var calendarId: String?;
    
    mutating func addDescription(descr: String) {
        
        description = descr;
    }
    
    mutating func toggleLocationTrack(status: Bool) {
        
        locationTrack = status;
    }
 
    mutating func setCalendarId(id: String) {
        
        calendarId = id;
    }
}
