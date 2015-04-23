//
//  SRPlacesTypesDataSource.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/25/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRPlacseTypesDataSource {
    
    private var types:[(name: String, value: String)] = [
        (name: NSLocalizedString("airport_type", comment:""), value: "airport"),
        (name: NSLocalizedString("amusement_park_type", comment:""), value: "amusement_park"),
        (name: NSLocalizedString("art_galery_type", comment:""), value: "art_gallery"),
        (name: NSLocalizedString("atm_type", comment:""), value: "atm"),
        (name: NSLocalizedString("bar_type", comment:""), value: "bar"),
        (name: NSLocalizedString("bakery_type", comment:""), value: "bakery"),
        (name: NSLocalizedString("bank_type", comment:""), value: "bank"),
        (name: NSLocalizedString("beaty_salon_type", comment:""), value: "beauty_salon"),
        (name: NSLocalizedString("book_store_type", comment:""), value: "book_store"),
        (name: NSLocalizedString("bowling_alley_type", comment:""), value: "bowling_alley"),
        (name: NSLocalizedString("cafe_type", comment:""), value: "cafe"),
        (name: NSLocalizedString("car_wash_type", comment:""), value: "car_wash"),
        (name: NSLocalizedString("casino_type", comment:""), value: "casino"),
        (name: NSLocalizedString("cemetery_type", comment:""), value: "cemetery"),
        (name: NSLocalizedString("church_type", comment:""), value: "church"),
        (name: NSLocalizedString("city_hall_type", comment:""), value: "city_hall"),
        (name: NSLocalizedString("clothing_store_type", comment:""), value: "clothing_store"),
        (name: NSLocalizedString("courthouse_type", comment:""), value: "courthouse"),
        (name: NSLocalizedString("embassy_type", comment:""), value: "embassy"),
        (name: NSLocalizedString("gym_type", comment:""), value: "gym"),
        (name: NSLocalizedString("hospital_type", comment:""), value: "hospital"),
        (name: NSLocalizedString("library_type", comment:""), value: "library"),
        (name: NSLocalizedString("night_club_type", comment:""), value: "night_club"),
        (name: NSLocalizedString("movie_theater_type", comment:""), value: "movie_theater"),
        (name: NSLocalizedString("museum_type", comment:""), value: "museum"),
        (name: NSLocalizedString("park_type", comment:""), value: "park"),
        (name: NSLocalizedString("pharmacy_type", comment:""), value: "pharmacy"),
        (name: NSLocalizedString("restaurant_type", comment:""), value: "restaurant"),
        (name: NSLocalizedString("train_station", comment:""), value: "train_station"),
        (name: NSLocalizedString("university_type", comment:""), value: "university"),
        (name: NSLocalizedString("zoo_type", comment:""), value: "zoo")
    ];
    
    init() {
        
        types.sort({ $0.name < $1.name });
    }
    
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