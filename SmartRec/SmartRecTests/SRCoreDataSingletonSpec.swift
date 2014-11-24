//
//  SRCoreDataSingletonSpec.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/24/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Quick
import Nimble
import SmartRec

class SRCoreDataSingletonSpec: QuickSpec {
    override func spec() {
        
        describe("a SRLocationManager") {
            
            context("when the manager initialized") {
                it("is not nil") {
                    expect(SRLocationManager.sharedInstance).notTo(beNil());
                }
                
                describe("and shredInstance") {
                    it("is defferent instanses") {
                        expect(SRLocationManager.sharedInstance === SRLocationManager()).notTo(beTruthy());
                    }
                }
                
                describe("and SRAccelerometerManager") {
                    it("is same instanse") {
                        expect(SRLocationManager.sharedInstance === SRLocationManager.sharedInstance).to(beTruthy());
                    }
                }
            }
        }
    }
}
