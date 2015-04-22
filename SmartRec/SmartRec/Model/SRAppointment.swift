//
//  SRAppointment.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/8/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

struct SRAppointment : SRSocialShareableItemProtocol {

    var id: String;
    var place: SRGooglePlace;
    var dateInSeconds: Double;
    var locationTrack: Bool;
    var description: String;
    var calendarId: String?;
    
    mutating func addDescription(descr: String) {
        
        description = descr;
    }
    
    mutating func toggleLocationTrack(status: Bool) {
        
        locationTrack = status;
    }
 
    mutating func setCalendarId(id: String) {
        
        calendarId = id;
    }
    
    func socialSharingMessageText() -> String {
        
        let fireDate = NSDate(timeIntervalSince1970: dateInSeconds);
        let fireDateString = "\(fireDate.stringFromDateWithStringFormats([kTimeFormat, kDateFormat, kTimeFormat]).capitalizedString)";
        let postText = place.name! + "\n" + place.formattedAddress!.capitalizedString + "\n" + fireDateString;
        
        return postText;
    }
    
    func socialSharingThumbnailUrl() -> NSURL? {
        
        if (place.photoReferences != nil && place.photoReferences!.count != 0) {
            
            let photoReference = place.photoReferences![0] as String!;
            
            var urlString = "\(kGooglePlacePhotoAPIURL)maxheight=\(kGooglePhotoMaxHeight)&photoreference=\(photoReference)&key=\(kGooglePlaceAPIKey)";
            urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!;
            
            return NSURL(string: urlString)!;
        }
        
        return nil;
    }
    
}
