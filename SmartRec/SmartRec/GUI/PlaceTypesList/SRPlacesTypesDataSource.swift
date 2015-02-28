//
//  SRPlacesTypesDataSource.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/25/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRPlacseTypesDataSource {
    
    private let types:[(name: String, value: String)] = [
        (name: "Airport", value: "airport"),
        (name: "Amusement park", value: "amusement_park"),
        (name: "Art Gallery", value: "art_gallery"),
        (name: "ATM", value: "atm"),
        (name: "Bar", value: "bar"),
        (name: "Bus Station", value: "bus_station"),
        (name: "Church", value: "church"),
        (name: "Museum", value: "museum"),
        (name: "Night Club", value: "night_club")
    ];
    
    //public interface
    
    func numberOfTypesInSection(sectionIndex: Int) -> Int {
        
        return self.types.count;
    }
    
    func numberOfSections() -> Int {
        
        return 1;
    }
    
    func typeAtIndex(index: Int) -> (name: String, value: String)? {
        
        if (index >= types.count) {
            return nil;
        } else {
            return types[index];
        }
    }
}