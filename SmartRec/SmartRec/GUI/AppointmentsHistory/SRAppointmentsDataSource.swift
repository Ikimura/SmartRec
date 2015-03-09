//
//  SRAppointmentsDataSource.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/9/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

protocol SRAppointmentsDataSourceProtocol {
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject;
    func indexpathForObject(object: AnyObject) -> NSIndexPath?;
    func numberOfSections() -> Int;
    func numberOfItemInSection(index: Int) -> Int;
        
    func rebuildDataSet();
}

protocol SRAppointmentsDataSourceDelegate {

    func dataSourceWillChangeContent(dataSource: SRAppointmentsDataSourceProtocol);
    func dataSourceDidChangeContent(dataSource: SRAppointmentsDataSourceProtocol);
}

class SRAppointmentsDataSource : SRAppointmentsDataSourceProtocol, NSFetchedResultsControllerDelegate {
    
    var dataSet: [AnyObject]? {
        
        get {
            return fetchResultController!.fetchedObjects;
        }
    }
    var delegate: SRAppointmentsDataSourceDelegate?;

    private var fetchResultController: NSFetchedResultsController?;
    private let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;

    init() {
        
        fetchResultController = NSFetchedResultsController(fetchRequest: self.fetchRequest(), managedObjectContext: appDelegate.coreDataManager.mainObjectContext, sectionNameKeyPath: "fireData", cacheName: nil);
        
        fetchResultController?.delegate = self;
        
        var error: NSError?;
        fetchResultController?.performFetch(&error);
        
        if (error != nil) {
            
            print(error);
        }
    }
    
    func sortDescriptor() -> [AnyObject] {
        
        return [ NSSortDescriptor(key: "fireData", ascending: true) ];
    }

    func fetchRequest() -> NSFetchRequest {
        
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "SRCoreDataAppointment");
        fetchRequest.sortDescriptors = self.sortDescriptor();
        
        return fetchRequest;
    }
    
    //MARK: - SRAppointmentsDataSourceProtocol
    
    func rebuildDataSet() {
        
        fatalError("Not Implemented");
    }

    func numberOfSections() -> Int {
        
        if (fetchResultController!.sections != nil) {
            
            return fetchResultController!.sections!.count;
        }
        
        return 0;
    }
    
    func numberOfItemInSection(index: Int) -> Int {
        
        var section = fetchResultController!.sections![index] as? NSFetchedResultsSectionInfo;
        
        return section!.numberOfObjects;
    }
    
    func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject {
        
        return fetchResultController!.objectAtIndexPath(indexPath);
    }
    
    func indexpathForObject(object: AnyObject) -> NSIndexPath? {
        
        return fetchResultController!.indexPathForObject(object);
    }
    
    //MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        delegate?.dataSourceWillChangeContent(self);
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        delegate?.dataSourceDidChangeContent(self);
    }
}
