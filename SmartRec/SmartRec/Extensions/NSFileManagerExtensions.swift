//
//  NSFileManagerExtensions.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/11/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation

enum SRResult {
    case Success(AnyObject!)
    case Failure(NSError)
}

extension NSFileManager {
    
    func removeItemWithURL(url: NSURL) -> SRResult {
        var error: NSError?;
        self.removeItemAtURL(url, error: &error);
    
        if error != nil {
            return .Failure(error!);
        }
        
        return .Success(true);
    }
    
}