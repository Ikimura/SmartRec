//
//  SRCoreDataManager.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/13/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import CoreData

class SRCoreDataManager: NSObject {
    
    class var sharedInstance: SRCoreDataManager {
        struct Static {
            static let instance: SRCoreDataManager = SRCoreDataManager();
        }
        return Static.instance;
    }
    
    //MARK: - life cycle
    
    override init() {
        super.init();
        
    }

    //MARK: - new public API
    
    func updateEntity(entity: NSManagedObject) -> SRResult {
        var managedContext = entity.managedObjectContext;
                
        var error: NSError?;
        
        if (managedContext?.save(&error) == true) {
            return .Success(true);
        }
        
        return .Failure(error!);
    }
    
    func deleteEntity(entity: String, withUniqueField indentifier: String, fromContext context: NSManagedObjectContext) -> SRResult {
        
        var entity = self.singleManagedObject(entity, withUniqueField: indentifier, inContext: context);
        
        return self.deleteEntity(entity!);
    }
    
    func deleteEntity(entity: NSManagedObject) -> SRResult {
        
        var context = entity.managedObjectContext;
        context?.deleteObject(entity);
        
        var error: NSError?;
        if (context?.save(&error) == true) {
            return .Success(true);
        }
        
        return .Failure(error!);
    }
    
    //MARK: - Utils
    
    func singleManagedObject(entityName: String, withUniqueField identifier: String, inContext context: NSManagedObjectContext) -> NSManagedObject? {
        
        var predicate: NSPredicate?
        if (entityName == kManagedObjectPlace) {
            
            predicate = NSPredicate(format: "placeId == %@", identifier)!;

        } else {
            
            predicate = NSPredicate(format: "id == %@", identifier)!;
        }
        
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: entityName);
        fetchRequest.predicate = predicate;
        
        var error: NSError?;
        var res: AnyObject? = context.executeFetchRequest(fetchRequest, error: &error)?.first;
        
        if error != nil {
            println(error);
        }
        
        return res as? NSManagedObject;
    }
    
    func findOrCreateManagedObject(entityName: String, predicate: NSPredicate, inContext: NSManagedObjectContext) -> NSManagedObject {
        
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: entityName);
        fetchRequest.predicate = predicate;
        fetchRequest.fetchLimit = 1;
        
        var entity: AnyObject? = inContext.executeFetchRequest(fetchRequest, error: nil)?.first;
        
        if (entity == nil) {
            
            println("New entity=\(entityName) created.");
            entity = NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: inContext) as? NSManagedObject;
        }
        
        return entity! as NSManagedObject;
    }
    
}
