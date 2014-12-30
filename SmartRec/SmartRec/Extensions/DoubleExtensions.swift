//
//  DoubleExtensions.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/30/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation

extension Double {
    
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self)
    }
}