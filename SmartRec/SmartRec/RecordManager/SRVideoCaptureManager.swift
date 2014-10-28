//
//  SRVideoCaptureManager.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/24/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation

protocol SRVideoCaptureManagerDelegateProtocol {
    func videoCaptureManagerCanGetPreviewView(captureSession: AVCaptureSession);
}

class SRVideoCaptureManager: NSObject, SRVideoRecorderDelegateProtocol {
    
    var currentRecorder: SRVideoRecorder!;
    var delegate: SRVideoCaptureManagerDelegateProtocol?;
    
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

        //secodnly start running
    }
    
    //MARK: public
    
    func startRecording() {
        let fileName = self.makeNewFilePath();
        NSLog(fileName);
        if let outputURL = NSURL.URL(directoryName: kFileDirectory, fileName: fileName) as NSURL! {
            isRecording = true;
            currentRecorder.url = outputURL;
            currentRecorder.startRecording();
        }
    }
    
    func stopRecording() {
        isRecording = false;
        currentRecorder.stopRecording();
    }
    
    func startRunnigSession() {
        currentRecorder.startRunning();
    }
    
    func stopRunnigSession() {
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
    
    func captureVideoRecordingDidStopRecoding(captureRecorder: SRVideoRecorder, withError error: NSError) {
        //start new video part recording
        NSLog("captureVideoRecordingDidStopRecoding - delegate");
        if isRecording == true {
            self.startRecording();
        }
    }
    
    func captureVideoRecordingPreviewView(captureRecorder: SRVideoRecorder) {
        NSLog("captureVideoRecordingPreviewView");
        delegate?.videoCaptureManagerCanGetPreviewView(currentRecorder.captureSession);
    }
}
