//
//  SRCoreDataSpec.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/24/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import CoreData
import Nimble
import Quick

class SRCoreDataSpec: QuickSpec {
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        return  NSManagedObjectModel.mergedModelFromBundles(nil)!;
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil);
        var tempStoreCordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!);
        let options: [String: Bool] = [
            NSMigratePersistentStoresAutomaticallyOption : true,
            NSInferMappingModelAutomaticallyOption : true
        ];
            
        let tempURLS = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask);
        
        let storeURL = (tempURLS[tempURLS.count - 1]).URLByAppendingPathComponent(kStorePathComponent);
        
        var error: NSError?;
        tempStoreCordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error);
    
        if error != nil {
            NSLog("\(error)");
        }
        
        return tempStoreCordinator;
    }();
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        var tempMain = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType);
        tempMain.persistentStoreCoordinator = self.persistentStoreCoordinator;
        
        return tempMain;
    }();

    override func spec() {
        afterSuite {
            self.managedObjectContext = nil;
        }
        
        describe("a CoreData") {
            // ...
            context("entity") {
                // ...none of the code in this closure will be run.
                it("SRRoute should not be nil") {
                    let entity = NSEntityDescription.entityForName(kManagedObjectRoute, inManagedObjectContext: self.managedObjectContext!);
                    let route = SRCoreDataRoute(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext);
                    expect(route).notTo(beNil());
                }
                
                xit("SRRouteMark should not be nil") {
                    expect(false).to(beTrue());
                }
                
                it("SRVideoData should not be nil") {
                    let entity = NSEntityDescription.entityForName(kManagedObjectVideoData, inManagedObjectContext: self.managedObjectContext!);
                    let videoData = SRVideoData(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext);
                    expect(videoData).notTo(beNil());
                }
                
                it("SRVideoMark should not be nil") {
                    let entity = NSEntityDescription.entityForName(kManagedObjectVideoMark, inManagedObjectContext: self.managedObjectContext!);
                    let videoMark = SRCoreDataRouteVideoPoint(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext);
                    expect(videoMark).notTo(beNil());
                }
            }
        }
    }
}
