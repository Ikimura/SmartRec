//
//  SRMotionManager.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/3/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import CoreMotion

public class SRGSensor: NSObject {
    
    public var accelerationValueDelta: Double;
    
    internal lazy var widgetView: SRGSensorView = {
        let temp = UIView.viewFromNibName("SRGSensorView") as SRGSensorView;
        return temp;
    }();
    
    private var motionManager: CMMotionManager!;
    private lazy var operationQueue: NSOperationQueue? = {
        return NSOperationQueue();
    }();
    
    private var accelerationXAverage: Double = 0.0;
    private var accelerationYAverage: Double = 0.0;
    private var accelerationZAverage: Double = 0.0;
    
    private var accelerationXSum: Double = 0.0;
    private var accelerationYSum: Double = 0.0;
    private var accelerationZSum: Double = 0.0;
    
    private var measuresCount: Double = 1.0;
    private var needView: Bool;
    /**
    * Magnifies the readings from the accelerometer for testing purposes
    */
    private var accelerationScale: Double = 1.0;

    
    public init(delta: Double, frequancy: Double, allowView: Bool) {
        accelerationValueDelta = delta;
        needView = allowView;
        motionManager = CMMotionManager();
        motionManager.accelerometerUpdateInterval = frequancy;
        super.init();
    }
    
    public func startAccelerationMonitoring() {
        
        motionManager.startAccelerometerUpdatesToQueue(self.operationQueue, withHandler: { [weak self] (accelerometerData: CMAccelerometerData!, error: NSError!) -> Void in
            
            if var blockSelf = self {
            
                //filtering noise
                if (fabs(accelerometerData.acceleration.x - blockSelf.accelerationXAverage) > blockSelf.accelerationValueDelta ||
                    fabs(accelerometerData.acceleration.y - blockSelf.accelerationYAverage) > blockSelf.accelerationValueDelta ||
                    fabs(accelerometerData.acceleration.z - blockSelf.accelerationZAverage) > blockSelf.accelerationValueDelta) {
                        
                    blockSelf.accelerationXSum = accelerometerData.acceleration.x;
                    blockSelf.accelerationYSum = accelerometerData.acceleration.y;
                    blockSelf.accelerationZSum = accelerometerData.acceleration.z;
                    
                    blockSelf.measuresCount = 1.0;
                        
                } else {
                    
                    blockSelf.accelerationXSum += accelerometerData.acceleration.x;
                    blockSelf.accelerationYSum += accelerometerData.acceleration.y;
                    blockSelf.accelerationZSum += accelerometerData.acceleration.z;
                    
                    blockSelf.measuresCount++;
                }
                
                blockSelf.accelerationXAverage = blockSelf.accelerationXSum/blockSelf.measuresCount;
                blockSelf.accelerationYAverage = blockSelf.accelerationYSum/blockSelf.measuresCount;
                blockSelf.accelerationZAverage = blockSelf.accelerationZSum/blockSelf.measuresCount;
                
                println("acceleration_x: \(accelerometerData.acceleration.x)");
                println("acceleration_y: \(accelerometerData.acceleration.y)");
                println("acceleration_z: \(accelerometerData.acceleration.z)");
                
                // Save ourselves a multiply if we can
                if (blockSelf.accelerationScale != 1.0) {
                    
                    blockSelf.accelerationXAverage *= blockSelf.accelerationScale;
                    blockSelf.accelerationYAverage *= blockSelf.accelerationScale;
                    blockSelf.accelerationZAverage *= blockSelf.accelerationScale;
                }
                
                // Check if we exceeded our max decel
                if(abs(blockSelf.accelerationXAverage) >= MAX_ALLOWED_DECELERATION ||
                    abs(blockSelf.accelerationYAverage) >= MAX_ALLOWED_DECELERATION ||
                    abs(blockSelf.accelerationZAverage) >= MAX_ALLOWED_DECELERATION) {
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("Occasion", object: nil);
                }

                if (blockSelf.needView == true) {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        blockSelf.widgetView.moveMarkerAccrodinglyAccelerationZ(blockSelf.accelerationXAverage, accelerationZ: blockSelf.accelerationZAverage);
                    });
                }
                
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
