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
        
        describe("a FileManager") {
            var fileName: String?;
            var fileURL: NSURL?;
            var fileData: NSString?;
            
            beforeEach({ () -> () in
                //arrange
                fileName = "temp.txt";
                fileData = "tempData";
                fileURL = NSURL.fileURLWithPath(NSTemporaryDirectory().stringByAppendingPathComponent(fileName!));
                
                let data: NSData = fileData!.dataUsingEncoding(NSUTF8StringEncoding)!;
                var error: NSError?;
                data.writeToURL(fileURL!, options: .AtomicWrite, error: &error);
            });
            
            context("can delete file") {
                it("with url") {
                    //act
                    let result: SRResult = NSFileManager.defaultManager().removeItemWithURL(fileURL!);
                    //assert
                    
                    switch result{
                    case .Success(let succes):
                        expect(true).to(beTruthy());
                    case .Failure(let errString):
                        expect(false).to(beTruthy());
                    }
                }
            }
        }
    }
}
