//
//  SRAppointmentsDataSource.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/9/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRAppointmentsDataSource : SRCoreDataDataSource, SRAppointmentsDataSourceProtocol, NSFetchedResultsControllerDelegate {
    
    var dataSet: [AnyObject]? {
        get {
            
            return fetchResultController?.fetchedObjects;
        }
    }
    
    override init() {
        super.init();
        
    }

    func sortDescriptor() -> [AnyObject] {
        
        return [ NSSortDescriptor(key: "fireDate", ascending: true) ];
    }

    override func fetchRequest() -> NSFetchRequest {
        
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: "SRCoreDataAppointment");
        fetchRequest.sortDescriptors = self.sortDescriptor();
        fetchRequest.predicate = self.compoundPredicate();
        
        return fetchRequest;
    }

    override func sectionNameKeyPath() -> String {
        
        return "sortDate";
    }
    
    private func compoundPredicate() -> NSPredicate {
        
        var predicates: [AnyObject] = [];
        
        predicates.append(NSPredicate(format: "completed == false")!);
        
        return NSCompoundPredicate(type: .AndPredicateType, subpredicates: predicates);
    }
    
    //MARK: - SRAppointmentsDataSourceProtocol
    
    override func refreshDataSet() {
        
        fetchResultController?.performFetch(nil);
        
        delegate?.dataSourceDidChangeDataSet(self);
    }
    
    override func rebuildDataSet() {
        
        var fetchedResultsController: NSFetchedResultsController? = nil;
        
        var fetchRequest: NSFetchRequest? = self.fetchRequest();
        
        if (self.fetchLimit != nil) {
            
            fetchRequest?.fetchLimit = self.fetchLimit!;
        }
        
        if (fetchRequest != nil) {
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest!, managedObjectContext: self.context(), sectionNameKeyPath: self.sectionNameKeyPath() , cacheName: nil);
            
            fetchedResultsController?.performFetch(nil);
            
            fetchedResultsController?.delegate = self;
            
        }
        
        self.fetchResultController = fetchedResultsController;
    }

    func numberOfSections() -> Int {
        
        if (fetchResultController!.sections != nil) {
            
            return fetchResultController!.sections!.count;
        }
        
        return 0;
    }
    
    func titleForHeaderInSection(section: Int) -> String {
        
        var section = fetchResultController!.sections![section] as? NSFetchedResultsSectionInfo;
        
        return section!.name != nil ? section!.name! : "No name";
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
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        delegate?.dataSourceDidChangeDataSet(self);
    }
}
