//
//  SRVideoRecorder.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/21/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation

class SRVideoRecorder: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    var captureSession: AVCaptureSession!;
    var videoDevice: AVCaptureDevice!;
    var videoConnection: AVCaptureConnection!;
    var videoFrameRate: Float!;
    var videoDimensions: CMVideoDimensions!;
    var videoFileOutput: AVCaptureMovieFileOutput!;
    var videoOrientation: AVCaptureVideoOrientation!;

    var url: NSURL!;
    
    var delegate: AnyObject?;
    
    init(wtihURL fileURL: NSURL) {
        url = fileURL;
        super.init();

        
        self.setupCaptureSession();
    }
    
    func setupCaptureSession() {
        if (captureSession != nil) {
            return;
        }
        
        captureSession = AVCaptureSession();
        
        //    /* Video */
        self.videoDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
        
        var videoIn: AVCaptureDeviceInput = AVCaptureDeviceInput(device: self.videoDevice, error: nil);
        
        if (captureSession.canAddInput(videoIn)) {
            captureSession.addInput(videoIn);
        }
        
        //video out
        videoFileOutput = AVCaptureMovieFileOutput();
        
        var duration: Float64 = 60;
        var frameRate: Int32;
        var sessionPreset = AVCaptureSessionPresetHigh;
        
        // For single core systems like iPhone 4 and iPod Touch 4th Generation we use a lower resolution and framerate to maintain real-time performance.
        if ( NSProcessInfo.processInfo().processorCount == 1 ) {
            
            if (captureSession.canSetSessionPreset(AVCaptureSessionPreset640x480)) {
                sessionPreset = AVCaptureSessionPreset640x480;
            }
            frameRate = 15;
            
        } else {
            if ( captureSession.canSetSessionPreset(AVCaptureSessionPreset1280x720)) {
                sessionPreset = AVCaptureSessionPreset1280x720;
            }
            
            frameRate = 30;
        }
        
        var maxDuration: CMTime = CMTimeMakeWithSeconds(duration, frameRate);	//<<SET MAX DURATION
        videoFileOutput.maxRecordedDuration = maxDuration;

        if (self.captureSession.canAddOutput(videoFileOutput)) {
            self.captureSession.addOutput(videoFileOutput);
        }
        
        videoOrientation = .Portrait;
        
        videoConnection = videoFileOutput.connectionWithMediaType(AVMediaTypeVideo);
        videoConnection.videoOrientation = videoOrientation;
    }
    
    func startRunning() {
        captureSession.startRunning();
    }
    
    func stopRunning() {
        captureSession.stopRunning();
    }
    
    func startRecording() {
        videoFileOutput.startRecordingToOutputFileURL(url, recordingDelegate: self);

    }
    
    func stopRecording() {
        videoFileOutput.stopRecording();
    }
    
    //MARK: - AVCaptureFileOutputRecordingDelegate
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        NSLog("didFinishRecordingToOutputFileAtURL - enter");
        
    }
}
