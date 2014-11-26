//
//  Constants.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/22/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import Foundation
import QuartzCore

let kVideoDuration: Float64 = 10;

let kLowFramRate: Int32 = 15;

let kHighFramRate: Int32 = 30;

let kFileDirectory: NSSearchPathDirectory = .DocumentDirectory;

let kManagedObjectVideoMark: String = "SRVideoMark";

let kManagedObjectVideoData: String = "SRVideoData";

let kManagedObjectRoute: String = "SRRoute";

let kMovieListCellIdentifier: String = "movieCellidentifier";

let kShowMovieSegueIdentifier: String = "showVideoIdentifier";

let kShowVideoDetailSegueIdentifier: String = "showVideoDetailItentifier";

let kStorePathComponent: String = "SmartRec.sqlite";

let kTestStorePathComponent: String = "SmartRecTest.sqlite";

let kGoogleMapsAPIKey: String = "AIzaSyDkaCDkatCMTXFFbC_cdRnkBC2KsGL7C3Q";

let kGoogleMapsAPIURL: String = "http://maps.googleapis.com/maps/api/directions/json";

let kThumbnailHeight: CGFloat = 64;

let kThumbnailWidth: CGFloat = 44;

let kFileNameFormat: String = "h:mm:s.SSa_d_M_y";

let kFileExtension: String = ".mov";

let kLocationTitleNotification: String = "SRLocationManagerDidUpdateLocations";
