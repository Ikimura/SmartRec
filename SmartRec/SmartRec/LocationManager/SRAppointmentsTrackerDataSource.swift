//
//  SRAppointmentsTrackerDataSource.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/11/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRAppointmentsTrackerDataSource : SRAppointmentsDataSource {

    override func fetchRequest() -> NSFetchRequest {
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "SRCoreDataAppointment");
        fetchRequest.sortDescriptors = self.sortDescriptor();
        fetchRequest.predicate = self.compoundPredicate();
        
        return fetchRequest;
    }
    
    private func compoundPredicate() -> NSPredicate {
        
        var predicates: [AnyObject] = [];
        
        predicates.append(NSPredicate(format: "locationTrack == true")!);
        
        predicates.append(NSPredicate(format: "completed == false")!);
        
        let trackDate = NSCalendar.currentCalendar().startOfDayForDate(NSDate());
        predicates.append(NSPredicate(format: "sortDate == %@", trackDate)!);
        
        return NSCompoundPredicate(type: .AndPredicateType, subpredicates: predicates);
    }
}