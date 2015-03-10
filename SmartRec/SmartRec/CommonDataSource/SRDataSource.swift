//
//  SRDataSource.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/10/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

protocol SRDataSourceDelegate {
 
    func dataSourceDidChangeDataSet(dataSource: SRDataSource);
}

class SRDataSource {
    
    var delegate: SRDataSourceDelegate?;
    
    init () {
        
    }

    /**
    Data source's objects. Default implementation returns empty array.
    */
    func dataSet() -> [AnyObject]? {
        
        return nil;
    }
    
    /**
    Tells the receiver to invalidate current data and rebuild the data set basing on a data stored in a local store. Default implementation does nothing.
    */
    func rebuildDataSet() {
        
    }
    
    /**
    Tells the receiver to load a data, put the data into a local store, and invalidate the data set. Default implementation does nothing.
    */
    
    func refreshDataSet() {
        
    }
}