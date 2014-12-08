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
///TODO: - detection

                if (fabs(accelerometerData.acceleration.z) - fabs(blockSelf.accelerationZAverage) > 0.5) {
                    NSNotificationCenter.defaultCenter().postNotificationName("Occasion", object: nil);
                    //notefiy video recorder about autosave
                }
            
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
                
//                //angle calculations_2
//                var zz = -blockSelf.accelerationZAverage;
//                var yy = blockSelf.accelerationYAverage;
//                var angle_1 = atan2(yy, zz);
//
                //angle calculations_2
//                var angle_2: Double = atan(blockSelf.accelerationZAverage/sqrt(pow(blockSelf.accelerationXAverage, 2.0) + pow(blockSelf.accelerationYAverage, 2.0)));//
//                var xx = -blockSelf.accelerationXAverage;
//                var yy = blockSelf.accelerationYAverage;
//                var angle_1 = atan2(yy, xx);
                
                
                
//                println("angle_1 rads: \(angle_1)");
//                println("angle_2 rads: \(angle_2)");
////
//                var angleDegrees_1: Double = (angle_1 * (180.0 / M_PI));
//                var angleDegrees_2: Double = (angle_2 * (180.0 / M_PI)) + 90;
////
////                
//                println("angle_1 deg: \(angleDegrees_1)");
//                println("angle_2 deg: \(angleDegrees_2)");
//                
//                println("acceleration_x: \(accelerometerData.acceleration.x)");
//                println("acceleration_z: \(accelerometerData.acceleration.z)");
////
//                println("acceleration_average_x: \(blockSelf.accelerationXAverage)");
//                println("acceleration_average_z: \(blockSelf.accelerationZAverage)");
////
//                blockSelf.accelX = accelerometerData.acceleration.x - ((accelerometerData.acceleration.x * blockSelf.kFilteringFactor) + (blockSelf.accelX * (1.0 - blockSelf.kFilteringFactor)));
//                blockSelf.accelY = accelerometerData.acceleration.y - ((accelerometerData.acceleration.y * blockSelf.kFilteringFactor) + (blockSelf.accelY * (1.0 - blockSelf.kFilteringFactor)));
//                blockSelf.accelZ = accelerometerData.acceleration.z - ((accelerometerData.acceleration.z * blockSelf.kFilteringFactor) + (blockSelf.accelZ * (1.0 - blockSelf.kFilteringFactor)));
//                // Use the acceleration data.
//                println("filtered_acceleration_x: \(blockSelf.accelX)");
//                println("filtered_acceleration_z: \(blockSelf.accelZ)");
                
                
//                var sinVal = sin((90 - angleDegrees_2)*M_PI/180)
//                var my_acceleration_z = blockSelf.accelerationZAverage + 1.0 * sinVal;
//                println("my_acceleration_z: \(my_acceleration_z)");
                
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
