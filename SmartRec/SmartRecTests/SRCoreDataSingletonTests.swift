//
//  SRCoreDataSingletonTests.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/13/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import XCTest
import SmartRec

class SRCoreDataSingletonTests: XCTestCase {

    func testSharedInstance() {
        let instance = SRCoreDataManager.sharedInstance;
        XCTAssertNotNil(instance, "");
    }
    
    func testSharedInstance_Unique() {
        let instance1 = SRCoreDataManager()
        let instance2 = SRCoreDataManager.sharedInstance
        XCTAssertFalse(instance1 === instance2)
    }
    
    func testSharedInstance_Twice() {
        let instance1 = SRCoreDataManager.sharedInstance
        let instance2 = SRCoreDataManager.sharedInstance
        XCTAssertTrue(instance1 === instance2)
    }
    
    func testSharedInstance_ThreadSafety() {
        var instance1 : SRCoreDataManager!
        var instance2 : SRCoreDataManager!
        
        let expectation1 = expectationWithDescription("Instance 1")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            instance1 = SRCoreDataManager.sharedInstance
            expectation1.fulfill()
        }
        let expectation2 = expectationWithDescription("Instance 2")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            instance2 = SRCoreDataManager.sharedInstance
            expectation2.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0) { (_) in
            XCTAssertTrue(instance1 === instance2)
        }
    }

}
