//
//  SRCoreDataManagerSpec.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/25/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import CoreData
import Nimble
import Quick
import SmartRec

class SRCoreDataManagerSpec: QuickSpec {
    
    var coredataManager: SRCoreDataManager?;
    var currentRouteData: [String: Any]?;
    var currentVideoMark: [String: Any]?;
    var currentVideoData: [String: Any]?;

    override func spec() {
        
        beforeSuite {
            self.coredataManager = SRCoreDataManager(storePath: kTestStorePathComponent);
        }
        
        afterSuite {
            
            self.coredataManager = nil;
            
            let storeURL: NSURL = NSURL.URL(directoryName: kFileDirectory, fileName: kTestStorePathComponent)!
            var fileManager: NSFileManager = NSFileManager.defaultManager();
            
            fileManager.removeItemAtPath(storeURL.path!, error: nil);
            
            var error: NSError?;
//            let str = NSString(contentsOfURL: storeURL, encoding: NSASCIIStringEncoding, error: &error)!;
//            
//            if(fileManager.fileExistsAtPath(str)){
//                fileManager.removeItemAtURL(storeURL, error:nil);
//            }
        }
        
        beforeEach {[unowned self] () -> () in
            self.currentRouteData = [
                "id": NSString.randomString(),
                "date": NSDate()
            ];
            println("id: %@", self.currentRouteData!["id"] as String);

            self.currentVideoMark = [
                "id": NSString.randomString(),
                "lat": 53.916667,
                "lng": 27.55,
            ];
            println("id: %@", self.currentVideoMark!["id"] as String);
            
            self.currentVideoData = [
                "id": NSString.randomString(),
                "name": "name",
                "date": NSDate()
            ];
            println("id: %@", self.currentVideoData!["id"] as String);
        }
        
        afterEach {
            self.coredataManager!.mainObjectContext.reset();
            self.currentRouteData = nil;
            self.currentVideoMark = nil;
            self.currentVideoData = nil;
        }
        
        describe("a CoreDataManager") {
            // ...
            context("can") {
                
                xit("insert SRRoute entity") {
                    //act
                    let videoData: NSManagedObject? = self.coredataManager!.insertEntity(kManagedObjectVideoMark, dectionaryData: self.currentRouteData!);
                    let currentID: String = self.currentRouteData!["id"] as String;
                    println("id: %@", currentID);
                    
                    expect(videoData).notTo(beNil());
                    expect((videoData as SRRoute).id).to(equal(currentID));
                }

                it("insert SRVideoMark entity") {
                    //act
                    let videoData: NSManagedObject? = self.coredataManager!.insertEntity(kManagedObjectVideoMark, dectionaryData: self.currentVideoMark!);
                    let currentID: String = self.currentVideoMark!["id"] as String;
                    println("id: %@", currentID);

                    expect(videoData).notTo(beNil());
                    expect((videoData as SRVideoMark).id).to(equal(currentID));
                }
                
                it("insert SRVideoData entity") {
                    //act
                    let videoData: NSManagedObject? = self.coredataManager!.insertEntity(kManagedObjectVideoData, dectionaryData: self.currentVideoData!);
                    let currentID: String = self.currentVideoData!["id"] as String;
                    println("id: %@", currentID);

                    expect(videoData).notTo(beNil());
                    expect((videoData as SRVideoData).id).to(equal(currentID));
                }
                
                it("add relation between SRRoute and SRVideoMark") {
                    //act
                    var route: SRRoute = self.coredataManager!.insertEntity(kManagedObjectRoute, dectionaryData: self.currentRouteData!) as SRRoute!;
                    var videoMark: SRVideoMark = self.coredataManager!.insertEntity(kManagedObjectVideoMark, dectionaryData: self.currentVideoMark!) as SRVideoMark!;
                    
                    let routeID: String = self.currentVideoMark!["id"] as String;
                    let videoMarkID: String = self.currentVideoMark!["id"] as String;
                    
                    self.coredataManager!.addRelationBetweenVideoMark(videoMark, andRute: route.id);
                    
                    //check
                    var fetchRequest: NSFetchRequest = NSFetchRequest();
                    let entity: NSEntityDescription = NSEntityDescription.entityForName(kManagedObjectRoute, inManagedObjectContext: self.coredataManager!.masterObjectContext)!;

                    fetchRequest.entity = entity;

                    let predicate: NSPredicate = NSPredicate(format: "id == %@", routeID)!;
                    fetchRequest.predicate = predicate;

                    var error: NSError?;
                    
                    var res: [AnyObject]? = self.coredataManager!.mainObjectContext.executeFetchRequest(fetchRequest, error: &error)!;
                    println(res?.count);
                    
                    let testRoute: SRRoute = res?[0] as SRRoute;
                    
                    //assert
                    expect(error).to(beNil());
                    expect(testRoute.id).to(equal(routeID));
                    expect(testRoute.videoMarks.count).to(equal(1));
                    expect(videoMark.id).to(equal(videoMarkID));
                }
                
                it("add relation between SRVideoMark and SRVideoData") {
                    let mark: SRVideoMark = self.coredataManager!.insertEntity(kManagedObjectVideoMark, dectionaryData: self.currentVideoMark!) as SRVideoMark!;
                    let currentID: String = self.currentVideoMark!["id"] as String;
                    
                    expect(mark.id).to(equal(currentID));
                    
                    self.coredataManager!.addRelationBetweenVideoData(self.currentVideoData!, andRouteMark: mark.id);
                    
                    //check
                    var fetchRequest: NSFetchRequest = NSFetchRequest();
                    let entity: NSEntityDescription = NSEntityDescription.entityForName(kManagedObjectVideoMark, inManagedObjectContext: self.coredataManager!.masterObjectContext)!;
                    
                    fetchRequest.entity = entity;
                    
                    let predicate: NSPredicate = NSPredicate(format: "id == %@", currentID)!;
                    fetchRequest.predicate = predicate;
                    
                    var error: NSError?;
                    
                    var res: [AnyObject]? = self.coredataManager!.mainObjectContext.executeFetchRequest(fetchRequest, error: &error)!;
                    println(res?.count);
                    
                    let testMark: SRVideoMark = res?[0] as SRVideoMark;
                    let videoDataID = self.currentVideoData!["id"] as String;
                    
                    //assert
                    expect(error).to(beNil());
                    expect(testMark.id).to(equal(currentID));
                    expect(testMark.videoData).notTo(beNil());
                    expect(testMark.videoData.id).to(equal(videoDataID));
                }
                
            }
        }
    }
}
