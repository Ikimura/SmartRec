//
//  SRVideoPlace.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation

import UIKit
import Foundation
import CoreLocation

class SRVideoPlace {
  
//    let videoIdentifier: String;
    let fileName: String;
    let date: String;
    let coordinate: CLLocationCoordinate2D;
    var photo: UIImage?;
  
    init(dictionary: [String: AnyObject!]) {
//        videoIdentifier = dictionary["id"] as String;
        date = dictionary["date"] as String;
        fileName = dictionary["fileName"] as String;
        
        let lat = dictionary["lat"] as? CLLocationDegrees!;
        let lng = dictionary["lng"] as? CLLocationDegrees!;
        coordinate = CLLocationCoordinate2DMake(lat!, lng!)
    
        if let temp = dictionary["photo"] as? UIImage {
            photo = temp;
        }
    }
}