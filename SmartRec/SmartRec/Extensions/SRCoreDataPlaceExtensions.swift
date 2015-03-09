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
    
}