//
//  SRAirDropSharingProtocol.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/4/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

protocol SRAirDropSharingProtocol {
    
    func shareItemWithAirDropSocialServices(item: NSURL);
}

protocol SRSocialSharingProtocol {
    
    func shareItemInSocialServices(item: SRSocialShareableItemProtocol, excludingServices excludeServices: [NSString!]);
}