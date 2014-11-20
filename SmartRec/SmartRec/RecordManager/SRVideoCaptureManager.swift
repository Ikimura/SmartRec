//
//  SRVideoCaptureManager.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/24/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

protocol SRVideoCaptureManagerDelegate {
    func videoCaptureManagerCanGetPreviewView(captureSession: AVCaptureSession);
    func videoCaptureManagerDidEndVideoPartRecording(captureManager: SRVideoCaptureManager);
}

class SRVideoCaptureManager: NSObject, SRVideoRecorderDelegate {
    
    var delegate: SRVideoCaptureManagerDelegate?;
    
    private lazy var dateFormatter: NSDateFormatter = {
        
        var tempDormatter = NSDateFormatter();
        tempDormatter.timeStyle = .MediumStyle;
        tempDormatter.dateStyle = .NoStyle;
        
        return tempDormatter;
    }();
    
    private var currentRecorder: SRVideoRecorder!;
    private var isRecording: Bool!;
    //FIXME: - fix
    private lazy var currentRecData: [String: AnyObject] = {
        var tempArray = [String: AnyObject]();
        
        return tempArray;
    }();
    //FIXME: - fix
    private lazy var routeData: [CLLocationCoordinate2D] = {
        var tempArray = [CLLocationCoordinate2D]();
        
        return tempArray;
        }();
    
    override init(){
        super.init();
        
        isRecording = false;
        
        //firstly init Recorder with capture session
        var duration: Float64 = kVideoDuration;
        var frameRate: Int32 = kHighFramRate;
        var sessionPreset = AVCaptureSessionPreset1280x720;
        var videoOrientation: AVCaptureVideoOrientation = .Portrait;
        
        currentRecorder = SRVideoRecorder(duration: duration, frameRate: frameRate, orientation: videoOrientation);
        currentRecorder.setDelegate(self, callbackQueue:dispatch_get_main_queue());

    }
    
    //MARK: - internal interface
    
    func startRecordingVideo() {
        //get notifications about position changing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdatedLocations:", name: "SRLocationManagerDidUpdateLocations", object: nil)
        
        let date = NSDate();
        let fileName = self.makeNewFilePath(date);
        
        currentRecData["id"] = String(date.hashValue);
        currentRecData["name"] = fileName;
        currentRecData["date"] = date;
        currentRecData["location"] = SRLocationManager.sharedInstance.currentLocation();
        
        NSLog(fileName);
        if let outputURL = NSURL.URL(directoryName: kFileDirectory, fileName: fileName) as NSURL! {
            isRecording = true;
            currentRecorder.url = outputURL;
            currentRecorder.startRecording();
        }
    }
    
    func stopRecordingVideo() {
        //delete observer
        NSNotificationCenter.defaultCenter().removeObserver(self)
        //clear data
        routeData.removeAll(keepCapacity: false);
        
        isRecording = false;
        currentRecorder.stopRecording();
    }
    
    func startRunnigSession() {
        currentRecorder.startRunning();
    }
    
    func stopRunnigSession() {
        if isRecording == true {
            isRecording = false;
            currentRecorder.stopRecording();
        }
        currentRecorder.stopRunning();
    }
    
    //MARK: - private methods
    
    private func makeNewFilePath(parameter: AnyObject!) -> String {
        //Create temporary URL to record to
        var fileStr: String = "";
        
        switch parameter {
            
        case is NSDate: fileStr = dateFormatter.stringFromDate(parameter as NSDate);
        case is String: fileStr += parameter as String;
        default:
            println("Error");
        }
        
        fileStr += ".mov";
        
        return fileStr.stringByReplacingOccurrencesOfString(" ", withString: "");
    }
    
    //MARK: - SRLocationManager notification
    
    func didUpdatedLocations(locations: AnyObject) {
        
        if let crnLoc = locations[locations.count - 1] as? CLLocation {
            //save location
            routeData.append(crnLoc.coordinate);
        }
    }
    
    //MARK - SRVideoRecorderDelegateProtocol
    
    func captureVideoRecordingDidStartRecoding(captureRecorder: SRVideoRecorder) {
        //delete old video part
        NSLog("captureVideoRecordingDidStartRecoding - delegate");
    }
    
    func captureVideoRecordingDidStopRecoding(captureRecorder: SRVideoRecorder, withError error: NSError?) {
        //start new video part recording
        NSLog("captureVideoRecordingDidStopRecoding - delegate");
        delegate?.videoCaptureManagerDidEndVideoPartRecording(self);
        
        //get url
        let url = NSURL.URL(directoryName: kFileDirectory, fileName: currentRecData["name"] as String)!;
        //get asset
        var thumbnailImage: UIImage?;
        if let sourceAsset = AVAsset.assetWithURL(url) as? AVAsset {
            let maxSize: CGSize = CGSizeMake(kThumbnailWidth, kThumbnailHeight);
            //get thumbnail image
            thumbnailImage = sourceAsset.thumbnailWithSize(size: maxSize);
            currentRecData["thumbnailImage"] = UIImageJPEGRepresentation(thumbnailImage, 1.0);
        }
        
        //add object
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {[unowned self] () -> Void in
            SRCoreDataManager.sharedInstance.insertObjcet(self.currentRecData, routeData: self.routeData);
        })
        
        //
        if isRecording == true {
            self.startRecordingVideo();
        }
    }
    
    func captureVideoRecordingPreviewView(captureRecorder: SRVideoRecorder) {
        NSLog("captureVideoRecordingPreviewView");
        delegate?.videoCaptureManagerCanGetPreviewView(currentRecorder.captureSession);
    }
}
