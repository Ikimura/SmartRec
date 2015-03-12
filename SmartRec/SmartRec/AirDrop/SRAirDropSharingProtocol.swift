//
//  SRAirDropSharingProtocol.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/4/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

public protocol SRAirDropSharingProtocol {
    
    var fileURL: NSURL? {get set}
    
    func shareVideoItem();

}

public protocol SRSocialSharingProtocol {
    
    func shareAppointmetnt();
}