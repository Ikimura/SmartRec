//
//  SRCoreDataDataSource.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/10/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

protocol SRAppointmentsDataSourceProtocol {
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject;
    func indexpathForObject(object: AnyObject) -> NSIndexPath?;
    func titleForHeaderInSection(section: Int) -> String;
    func numberOfSections() -> Int;
    func numberOfItemInSection(index: Int) -> Int;
    
    func rebuildDataSet();
    func refreshDataSet();
}

class SRCoreDataDataSource: SRDataSource {
    
    var fetchLimit: Int?;
    
    var fetchResultController: NSFetchedResultsController?;

    private let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
    
    override init() {
        super.init();
    }
    
    /**
    The managed object context the data source works with.
    */
    
    func context() -> NSManagedObjectContext {
        
        return SRCoreDataContextProvider.mainManagedObjectContext();
    }
    
    func fetchRequest() -> NSFetchRequest? {
        
        return nil;
    }
    
    func sectionNameKeyPath() -> String? {
        
        return nil;
    }
}