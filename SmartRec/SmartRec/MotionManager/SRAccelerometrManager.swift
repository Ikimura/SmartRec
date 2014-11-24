//
//  SRMotionManager.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/3/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import CoreMotion

protocol SRAccelerometrManagerDelegate {
    func accelerometrManagerDidUpdateData(accelaration: CMAccelerometerData!);
}

public class SRAccelerometrManager: NSObject {
    public class var sharedInstance : SRAccelerometrManager {
        struct Static {
            static let instance : SRAccelerometrManager = SRAccelerometrManager();
        }
        return Static.instance;
    }
    
    var delegate: SRAccelerometrManagerDelegate?;
    
    private var motionManager: CMMotionManager!;
    private var operationQueue: NSOperationQueue?;
    
    public override init() {
        motionManager = CMMotionManager();
        
        super.init();
    }
    
    private func setUpManager(withInterval: NSTimeInterval) {
        motionManager.accelerometerUpdateInterval = withInterval;
        if operationQueue == nil {
            operationQueue = NSOperationQueue();
        }
    }
    
    public func startAccelerationMonitoring(withInterval: NSTimeInterval) {
        
        self.setUpManager(withInterval);
        
        motionManager.startAccelerometerUpdatesToQueue(operationQueue, withHandler: { [weak self] (accelerometerData: CMAccelerometerData!, error: NSError!) -> Void in
            
            if var blockSelf = self {
                blockSelf.delegate?.accelerometrManagerDidUpdateData(accelerometerData);
                
                if error != nil {
                    NSLog("%@", error);
                }
            }
        });
    }
    
    public func stopAccelerationMonitoring() {
        motionManager.stopAccelerometerUpdates();
    }
}
