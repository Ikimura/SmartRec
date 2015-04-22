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
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: kManagedObjectAppointment);
        fetchRequest.sortDescriptors = self.sortDescriptor();
        fetchRequest.predicate = self.compoundPredicate();
        
        return fetchRequest;
    }
    
    private func compoundPredicate() -> NSPredicate {
        
        var predicates: [AnyObject] = [];
        
        predicates.append(NSPredicate(format: "locationTrack == true")!);
        predicates.append(NSPredicate(format: "completed == false")!);
        
        //FIXME: - !!!
//        let trackDate = NSCalendar.currentCalendar().startOfDayForDate(NSDate());
//        predicates.append(NSPredicate(format: "sortDate == %@", trackDate.timeIntervalSinceReferenceDate)!);
        
        return NSCompoundPredicate(type: .AndPredicateType, subpredicates: predicates);
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch(type) {
            
        case .Insert:
            
            delegate?.dataSourceDidInsert(object: anObject, atIndexPath: newIndexPath);
            break;
            
        case .Delete:
            
            delegate?.dataSourceDidDelete(object: anObject, atIndexPath: indexPath);
            break;
            
        case .Update:
            delegate?.dataSourceDidUpdate(object: anObject, atIndexPath: indexPath);
            break;
            
        default:
            println("Not hanlde move");
        }
    }
}