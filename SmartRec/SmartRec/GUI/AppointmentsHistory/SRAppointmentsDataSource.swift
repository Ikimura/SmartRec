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
    
//    PARENT
    
    /*
    @interface LGIDataSource : NSObject
    
    @property (weak, nonatomic) IBOutlet id<LGIDataSourceDelegate> delegate;
    
    
    /**
    Data source's objects. Default implementation returns empty array.
    */
    - (NSArray *)dataSet;
    
    /**
    Tells the receiver to invalidate current data and rebuild the data set basing on a data stored in a local store. Default implementation does nothing.
    */
    - (void)rebuildDataSet;
    
    /**
    Tells the receiver to load a data, put the data into a local store, and invalidate the data set. Default implementation does nothing.
    */
    - (void)refreshDataSet;
    
    @end
    */
    
    /*
    - (NSArray *)dataSet {
    
    return nil;
    }
    
    - (void)rebuildDataSet {
    }
    
    
    - (void)refreshDataSet {
    }

    */
    
    /*
    @interface LGICoreDataDataSource : LGIDataSource
    
    - (NSManagedObjectContext *)context {
    
    return [LGICoreDataContextProvider mainManagedObjectContext];
    }

    - (void)refreshDataSet
    {
    
    [self.fetchedResultsController performFetch:NULL];
    
    if ([self.delegate respondsToSelector:@selector(dataSourceDidChangeDataSet:)]) {
    
    [self.delegate dataSourceDidChangeDataSet:self];
    }
    }
    
    - (void)rebuildDataSet {
    
    NSFetchedResultsController *fetchedResultsController = nil;
    NSFetchRequest *fetchRequest = [self fetchRequest];
    
    if (self.fetchLimit) {
    fetchRequest.fetchLimit = self.fetchLimit;
    }
    
    if (fetchRequest) {
    
    fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self context] sectionNameKeyPath:[self sectionNameKeyPath] cacheName:nil];
    
    [fetchedResultsController performFetch:NULL];
    
    fetchedResultsController.delegate = self;
    }
    
    self.fetchedResultsController = fetchedResultsController;
    
    
    }
    
    /**
    The managed object context the data source works with.
    */
    - (NSManagedObjectContext *)context;
    
    /**
    The fetch request which is used to get the objects. The fetch request must have at least one sort descriptor.
    */
    - (NSFetchRequest *)fetchRequest;
    
    
    @property (nonatomic) NSInteger fetchLimit;
    
    
    
    @property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
    
    @end
    */

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
