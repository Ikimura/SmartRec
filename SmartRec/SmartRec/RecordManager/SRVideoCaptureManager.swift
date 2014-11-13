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
    
    var currentRecorder: SRVideoRecorder!;
    var delegate: SRVideoCaptureManagerDelegate?;
    
    private lazy var dateFormatter: NSDateFormatter = {
        
        var tempDormatter = NSDateFormatter();
        tempDormatter.timeStyle = .MediumStyle;
        tempDormatter.dateStyle = .NoStyle;
        
        return tempDormatter;
    }();
    
    private var isRecording: Bool!;
    private lazy var currentRecData: [String: AnyObject] = {
        var tempArray = [String: AnyObject]();
        
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
    
    //MARK: public
    
    func startRecordingVideo() {
        let date = NSDate();
        let fileName = self.makeNewFilePath(date);
        
        currentRecData["id"] = String(date.hashValue);
        currentRecData["name"] = fileName;
        currentRecData["date"] = date;
        
        NSLog(fileName);
        if let outputURL = NSURL.URL(directoryName: kFileDirectory, fileName: fileName) as NSURL! {
            isRecording = true;
            currentRecorder.url = outputURL;
            currentRecorder.startRecording();
        }
    }
    
    func stopRecordingVideo() {
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
    
    //MARK: private
    
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
            let maxSize: CGSize = CGSizeMake(44, 64);
            //get thumbnail image
            thumbnailImage = sourceAsset.thumbnailWithSize(size: maxSize);
        }
        
        //save managed context
        let tempMain: NSManagedObjectContext! = SRCoreDataManager.sharedInstance.mainObjectContext;
        
        var entity = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectNote, inManagedObjectContext: tempMain) as SRNote;
        entity.id = currentRecData["id"] as String;
        entity.fileName = currentRecData["name"] as String;
        entity.date = currentRecData["date"] as NSDate;
        entity.imageThumbnail = UIImageJPEGRepresentation(thumbnailImage, 1.0);

        var error: NSError?;
        if tempMain?.save(&error) == false {
            println(error);
        }
        
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
