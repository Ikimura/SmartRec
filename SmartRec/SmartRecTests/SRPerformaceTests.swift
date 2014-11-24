//
//  SRExtensionsTest.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/12/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//
import XCTest
import SmartRec

class SRPerformaceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testURL_Creation() {
        let fileName = "my_file";
        let url = NSURL.URL(directoryName: .DocumentDirectory, fileName: fileName)!;
        
        XCTAssertNotNil(url);
    }
    
    func testURLCreater_Performance() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            let fileName = "my_file";
            let url = NSURL.URL(directoryName: .DocumentDirectory, fileName: fileName)!;
        }
    }
    
    func testRandomString_Performance() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            let id = String.randomString();
        }
    }
    
    func testStringFromDateConverting_Performance() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
            let fileName = String.stringFromDate(NSDate(), withFormat: kFileNameFormat);
        }
    }
    
}
