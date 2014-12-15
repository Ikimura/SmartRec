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

class SRCoreDataManagerSpec: QuickSpec {
    
    var coredataManager: SRCoreDataManager?;
    var currentVideoMark: SRVideoMarkStruct = SRVideoMarkStruct(id: NSString.randomString(), lng: 27.55, lat: 53.916667, autoSave: false, image: nil);;
    var currentVideoData: SRVideoDataStruct = SRVideoDataStruct(id: NSString.randomString(), fileName: "name", dateSeconds: NSDate().timeIntervalSince1970);
    var currentRouteData: SRRouteStruct = SRRouteStruct(id: NSString.randomString(), dateSeconds: NSDate().timeIntervalSince1970);

    override func spec() {
        
        
        beforeSuite {
            self.coredataManager = SRCoreDataManager(storePath: kStorePathComponent);
        }
        
        afterSuite {
            
            self.coredataManager = nil;
            
//            let storeURL: NSURL = NSURL.URL(directoryName: kFileDirectory, fileName: kStorePathComponent)!
//            var fileManager: NSFileManager = NSFileManager.defaultManager();
//            
//            fileManager.removeItemAtPath(storeURL.path!, error: nil);
////
//            var error: NSError?;
//            if let str = NSString(contentsOfURL: storeURL, encoding: NSASCIIStringEncoding, error: &error) as NSString! {
//                if(fileManager.fileExistsAtPath(str)){
//                    fileManager.removeItemAtURL(storeURL, error:nil);
//                }
//            }
        }
        
        afterEach {
            self.coredataManager!.mainObjectContext.reset();
        }
        
        describe("a CoreDataManager") {
            // ...
            context("can") {
                
                it("insert SRRoute entity") {
                    //act
                    let route: NSManagedObject? = self.coredataManager!.insertRouteEntity(self.currentRouteData);
                    let currentID: String = self.currentRouteData.id;
                    println("id: ", currentID);
                    
                    //asset
                    expect(route).notTo(beNil());
//                    expect((route as SRRoute).id).notTo(beNil());
                }

                it("insert SRVideoMark entity") {
                    //act
                    let videoMark: NSManagedObject? = self.coredataManager!.insertVideoMarkEntity(self.currentVideoMark);
                    let currentID: String = self.currentVideoMark.id;
                    println("id: %@", currentID);

                    expect(videoMark).notTo(beNil());
//                    expect((videoData as SRVideoMark).id).to(equal(currentID));
                }
                
                it("insert SRVideoData entity") {
                    //act
                    let videoData: NSManagedObject? = self.coredataManager!.insertVideoDataEntity(self.currentVideoData);
                    let currentID: String = self.currentVideoData.id;
                    println("id: %@", currentID);

                    expect(videoData).notTo(beNil());
//                    expect((videoData as SRVideoData).id).to(equal(currentID));
//                    expect(false).to(beTruthy());
                }
                
                it("delete SRRoute entity") {
                    //arrange
                    let route: NSManagedObject? = self.coredataManager!.insertRouteEntity(self.currentRouteData);
                    let currentID: String = self.currentRouteData.id;
                    println("id: ", currentID);
                    
                    //
                    expect(route).notTo(beNil());
                    //act
                    let result: SRResult = self.coredataManager!.deleteEntity(route!);
                    
                    //assert
                    switch result{
                    case .Success(let succes):
                        expect(true).to(beTruthy());
                    case .Failure(let errString):
                        expect(false).to(beTruthy());
                    }
                    
                }
                
                it("add relation between SRRoute and SRVideoMark") {
                    //act
//                    var route: SRRoute = self.coredataManager!.insertEntity(kManagedObjectRoute, dectionaryData: self.currentRouteData!) as SRRoute!;
//                    var videoMark: SRVideoMark = self.coredataManager!.insertEntity(kManagedObjectVideoMark, dectionaryData: self.currentVideoMark!) as SRVideoMark!;
//                    
//                    let routeID: String = self.currentVideoMark!.id;
//                    let videoMarkID: String = self.currentVideoMark!.id;
//                    
//                    self.coredataManager!.addRelationBetweenVideoMark(videoMark, andRute: route.id);
//                    
//                    //check
//                    var fetchRequest: NSFetchRequest = NSFetchRequest();
//                    let entity: NSEntityDescription = NSEntityDescription.entityForName(kManagedObjectRoute, inManagedObjectContext: self.coredataManager!.masterObjectContext)!;
//
//                    fetchRequest.entity = entity;
//
//                    let predicate: NSPredicate = NSPredicate(format: "id == %@", routeID)!;
//                    fetchRequest.predicate = predicate;
//
//                    var error: NSError?;
//                    
//                    var res: [AnyObject]? = self.coredataManager!.mainObjectContext.executeFetchRequest(fetchRequest, error: &error)!;
//                    println(res?.count);
//                    
//                    let testRoute: SRRoute = res?[0] as SRRoute;
//                    
//                    //assert
//                    expect(error).to(beNil());
//                    expect(testRoute.id).to(equal(routeID));
//                    expect(testRoute.videoMarks.count).to(equal(1));
//                    expect(videoMark.id).to(equal(videoMarkID));
                    expect(false).to(beTruthy());

                }
                
                it("add relation between SRVideoMark and SRVideoData") {
//                    let mark: SRVideoMark = self.coredataManager!.insertEntity(kManagedObjectVideoMark, dectionaryData: self.currentVideoMark!) as SRVideoMark!;
//                    let currentID: String = self.currentVideoMark!.id;
//                    
//                    expect(mark.id).to(equal(currentID));
//                    
//                    self.coredataManager!.addRelationBetweenVideoData(self.currentVideoData!, andRouteMark: mark.id);
//                    
//                    //check
//                    var fetchRequest: NSFetchRequest = NSFetchRequest();
//                    let entity: NSEntityDescription = NSEntityDescription.entityForName(kManagedObjectVideoMark, inManagedObjectContext: self.coredataManager!.masterObjectContext)!;
//                    
//                    fetchRequest.entity = entity;
//                    
//                    let predicate: NSPredicate = NSPredicate(format: "id == %@", currentID)!;
//                    fetchRequest.predicate = predicate;
//                    
//                    var error: NSError?;
//                    
//                    var res: [AnyObject]? = self.coredataManager!.mainObjectContext.executeFetchRequest(fetchRequest, error: &error)!;
//                    println(res?.count);
//                    
//                    let testMark: SRVideoMark = res?[0] as SRVideoMark;
//                    let videoDataID = self.currentVideoData!.id;
//                    
//                    //assert
//                    expect(error).to(beNil());
//                    expect(testMark.id).to(equal(currentID));
//                    expect(testMark.videoData).notTo(beNil());
//                    expect(testMark.videoData.id).to(equal(videoDataID));
                        expect(false).to(beTruthy());

                }
                
            }
        }
    }
}
