//
//  SRVideoDataTestCase.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/18/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import XCTest
import CoreData

class SRManagedObjectsTestCase: SRCoreDataTestCase {

    var videoData: SRVideoData?;
    var route: SRRoute?;

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

    }

    func testThatWeCanCreateSRVideoData() {
        let entity = NSEntityDescription.entityForName("SRVideoData", inManagedObjectContext: managedObjectContext!);
        videoData = SRVideoData(entity: entity!, insertIntoManagedObjectContext: managedObjectContext);
        
        XCTAssertNotNil(self.videoData, "unable to create a boss");
    }
    
    func testThatWeCanCreateSRRoute() {
        let entity = NSEntityDescription.entityForName("SRRoute", inManagedObjectContext: managedObjectContext!);
        route = SRRoute(entity: entity!, insertIntoManagedObjectContext: managedObjectContext);
        
        XCTAssertNotNil(self.route, "unable to create a boss");
    }

    override func tearDown() {
        videoData = nil;
        route = nil;
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
