//
//  SRSocialShareableItemProtocol.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/23/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

protocol SRSocialShareableItemProtocol {
    
    func socialSharingMessageText() -> String;
    func socialSharingThumbnailUrl() -> NSURL?;
}
