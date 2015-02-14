//
//  SRSettingsManager.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/10/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import AVFoundation

protocol SRSettingsManagerDelegate {
    
    func settingsDidChange();
}

public enum SRVideoQuality: Int32 {
    case Low = 0
    case Medium = 1
    case High = 2
}

public class SRSettingsManager: NSObject {
    
    var delegate: SRSettingsManagerDelegate?;
    
    private var frameRateUpdated = true;
    private var videoQualityUpdated = true;
    private var videorDurationUpdated = true;
    
    let userDfaults: NSUserDefaults = NSUserDefaults.standardUserDefaults();

    var frameRate: NSNumber {
        get {
            if (frameRateUpdated == true) {
                if let value: NSNumber = userDfaults.valueForKey(kFrameRateSettingsKey) as? NSNumber {
                    frameRateUpdated = false;
                    return value;
                } else {
                    return NSNumber(int: kDefaultFramRate);
                }
            } else {
                return NSNumber(int: kDefaultFramRate);
            }
        }
    };
    
    var videoQuality: NSNumber {
        get {
            if (videoQualityUpdated == true) {
                if let value: NSNumber = userDfaults.valueForKey(kQualitySettingsKey) as? NSNumber {
                    videoQualityUpdated = false;
                    return value;
                } else {
                    return NSNumber(int: kDefaultVideoQuality);
                }
            } else {
                return NSNumber(int: kDefaultVideoQuality);
            }
        }
    }
    
    var videoDuration: NSNumber {
        get {
            if (videorDurationUpdated == true) {
                if let value: NSNumber = userDfaults.valueForKey(kDurationSettingsKey) as? NSNumber {
                    videorDurationUpdated = false;
                    return value;
                } else {
                    return NSNumber(double: kDefaultVideoDuration);
                }
            } else {
                return NSNumber(double: kDefaultVideoDuration);
            }
        }
    }
    
    override init() {
        super.init();
        
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter();
        center.addObserver(self, selector: "defaultsChanged:", name: NSUserDefaultsDidChangeNotification, object: nil);
    }
    
    public func defaultsChanged(notification: NSNotification) {
        
        frameRateUpdated = true;
        videoQualityUpdated = true;
        videorDurationUpdated = true;
        
        delegate?.settingsDidChange();
    }
    
    deinit {
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter();
        center.removeObserver(self);
    }
    
}
