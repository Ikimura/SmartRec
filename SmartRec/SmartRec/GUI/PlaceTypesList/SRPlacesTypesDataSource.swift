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
        (name: "Bakery", value: "bakery"),
        (name: "Bank", value: "bank"),
        (name: "Beauty Salon", value: "beauty_salon"),
        (name: "Book Store", value: "book_store"),
        (name: "Bowling Alley", value: "bowling_alley"),
        (name: "Cafe", value: "cafe"),
        (name: "Car Wash", value: "car_wash"),
        (name: "Casino", value: "casino"),
        (name: "Cemetery", value: "cemetery"),
        (name: "Church", value: "church"),
        (name: "City Hall", value: "city_hall"),
        (name: "Clothing Store", value: "clothing_store"),
        (name: "Courthouse", value: "courthouse"),
        (name: "Embassy", value: "embassy"),
        (name: "Gym", value: "gym"),
        (name: "Hospital", value: "hospital"),
        (name: "Library", value: "library"),
        (name: "Night Club", value: "night_club"),
        (name: "Movie Theater", value: "movie_theater"),
        (name: "Museum", value: "museum"),
        (name: "Park", value: "park"),
        (name: "Pharmacy", value: "pharmacy"),
        (name: "Restaurant", value: "restaurant"),
        (name: "Train Station", value: "train_station"),
        (name: "University", value: "university"),
        (name: "Zoo", value: "zoo")
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