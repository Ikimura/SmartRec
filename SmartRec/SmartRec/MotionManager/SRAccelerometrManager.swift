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

class SRAccelerometrManager: NSObject {
    class var sharedInstance : SRAccelerometrManager {
        struct Static {
            static let instance : SRAccelerometrManager = SRAccelerometrManager();
        }
        return Static.instance;
    }
    
    var delegate: SRAccelerometrManagerDelegate?;
    
    private var motionManager: CMMotionManager!;
    private var operationQueue: NSOperationQueue?;
    
    override init() {
        motionManager = CMMotionManager();
        
        super.init();
    }
    
    private func setUpManager(withInterval: NSTimeInterval) {
        motionManager.accelerometerUpdateInterval = withInterval;
        if operationQueue == nil {
            operationQueue = NSOperationQueue();
        }
    }
    
    func startAccelerationMonitoring(withInterval: NSTimeInterval) {
        
        self.setUpManager(withInterval);
        
        motionManager.startAccelerometerUpdatesToQueue(operationQueue, withHandler: { [unowned self] (accelerometerData: CMAccelerometerData!, error: NSError!) -> Void in
            self.delegate?.accelerometrManagerDidUpdateData(accelerometerData);
            
            if error != nil {
                NSLog("%@", error);
            }
        });
    }
    
    func stopAccelerationMonitoring() {
        motionManager.stopAccelerometerUpdates();
    }
}
