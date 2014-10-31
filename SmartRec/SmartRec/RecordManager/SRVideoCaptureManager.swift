//
//  SRVideoCaptureManager.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/24/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    var isRecording: Bool!;
    
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
        let fileName = self.makeNewFilePath();
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
    
    private func makeNewFilePath() -> String {
        //Create temporary URL to record to
        
        var fileStr: String = dateFormatter.stringFromDate(NSDate());
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
        if isRecording == true {
            self.startRecordingVideo();
        }
    }
    
    func captureVideoRecordingPreviewView(captureRecorder: SRVideoRecorder) {
        NSLog("captureVideoRecordingPreviewView");
        delegate?.videoCaptureManagerCanGetPreviewView(currentRecorder.captureSession);
    }
}
