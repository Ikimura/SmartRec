//
//  SRRecordedRoutesDataSource.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/10/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRRecordedRoutesDataSource : SRAppointmentsDataSource {
    
    override func fetchRequest() -> NSFetchRequest {
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: kManagedObjectVideoMark);
        fetchRequest.sortDescriptors = self.sortDescriptor();
        
        return fetchRequest;
    }
    
    override func sectionNameKeyPath() -> String {
        
        return "route.id";
    }
    
    override func sortDescriptor() -> [AnyObject] {
        
        return [ NSSortDescriptor(key: "videoData.date", ascending: true) ];
    }
    
    override func titleForHeaderInSection(section: Int) -> String {
        
        var point = self.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: section)) as? SRRouteVideoPoint;
        
        var date = NSDate(timeIntervalSince1970: point!.route!.startDate);
        var sectionName = date.humantReadableStringDateFromDate(kDateFormat);
        
        return sectionName;
    }
    
}