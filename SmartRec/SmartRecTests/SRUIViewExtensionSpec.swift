//
//  SRUIViewExtensionSpec.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/24/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Quick
import Nimble
import SmartRec

class SRUIViewExtensionSpec: QuickSpec {
    override func spec() {
        
        describe("a UIView") {
            
            context("when loading from xib with nib name") {
                it("is not nil") {
                    expect(UIView.viewFromNibName("SRMarkerInfoView")).notTo(beNil());
                }
            }
        }
    }
}
