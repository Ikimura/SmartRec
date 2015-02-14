//
//  SRVideoRecorder.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/21/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation

protocol SRVideoRecorderDelegate {
    func captureVideoRecordingDidStartRecoding(captureRecorder: SRVideoRecorder);
    func captureVideoRecordingDidStopRecoding(captureRecorder: SRVideoRecorder, withError error: NSError?);
    
    func captureVideoRecordingWillUpdateCurrentSession(captureRecorder: SRVideoRecorder);
    func captureVideoRecordingDidUpdateCurrentSession(captureRecorder: SRVideoRecorder);
}

class SRVideoRecorder: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    var captureSession: AVCaptureSession!;
    var url: NSURL?;
    var videoOrientation: AVCaptureVideoOrientation!;
    var videoQuality: SRVideoQuality!;
    var videoDuration: Float64!;
    var delegate: SRVideoRecorderDelegate?;
    var videoFrameRate: Int32!;
    var isRunning: Bool? { get {
            return captureSession?.running;
        }
    }
    var isInterrupted: Bool? { get {
        return captureSession?.interrupted;
        }
    }
    
    private var videoDevice: AVCaptureDevice!;
    private var videoFileOutput: AVCaptureMovieFileOutput!;
    private var sessionQueue: dispatch_queue_t!;
    private var delegateCallbackQueue: dispatch_queue_t!;

    init(duration: Float64, frameRate: Int32, quality: SRVideoQuality, orientation: AVCaptureVideoOrientation) {
        super.init();
                
        videoDuration = duration;
        videoFrameRate = frameRate;
        videoOrientation = orientation;
        videoQuality = quality;
        
        sessionQueue = dispatch_queue_create( "con.epam.evnt.SmartRec.session", DISPATCH_QUEUE_SERIAL );
    }
    
    deinit{
        
    }
    
    //MARK: - private methods
    
    private func setupCaptureSession() {
        
        if (captureSession == nil) {
            
            dispatch_async(delegateCallbackQueue, { [weak self] () -> Void in
                if var blockSelf = self {
                    blockSelf.delegate?.captureVideoRecordingWillUpdateCurrentSession(blockSelf);
                }
            });

            captureSession = AVCaptureSession();
            
            if (captureSession.inputs.count > 0) {
                captureSession.removeInput(captureSession.inputs[0] as AVCaptureInput);
            }
            
            
            videoDevice = self.anyCaptureDevice();
            
            var videoIn: AVCaptureDeviceInput = AVCaptureDeviceInput(device: self.videoDevice, error: nil);
            
            if (captureSession.canAddInput(videoIn)) {
                captureSession.addInput(videoIn);
            }
            
            //video out
            var fileOutput = AVCaptureMovieFileOutput();
            videoFileOutput = fileOutput;
            
            var sessionPreset: AnyObject?;
            
            switch (videoQuality!) {
            case .High:
                // For single core systems like iPhone 4 and iPod Touch 4th Generation we use a lower resolution and framerate to maintain real-time performance.
                if ( NSProcessInfo.processInfo().processorCount != 1 ) {
                    if (captureSession.canSetSessionPreset(AVCaptureSessionPreset1280x720)) {
                        sessionPreset = AVCaptureSessionPreset1280x720;
                    } else {
                        fallthrough;
                    }
                } else {
                    fallthrough;
                }
            case .Medium:
                if (captureSession.canSetSessionPreset(AVCaptureSessionPreset640x480)) {
                    sessionPreset = AVCaptureSessionPreset640x480;
                    videoFrameRate = kLowFramRate;
                } else{
                    fallthrough;
                }
            case .Low:
                if (captureSession.canSetSessionPreset(AVCaptureSessionPreset352x288)) {
                    sessionPreset = AVCaptureSessionPreset352x288;
                    videoFrameRate = kLowFramRate;
                }
            default:
                break;
            }
            
            var maxDuration: CMTime = CMTimeMakeWithSeconds(videoDuration, videoFrameRate);	//<<SET MAX DURATION
            videoFileOutput.maxRecordedDuration = maxDuration;
            
            if (self.captureSession.canAddOutput(videoFileOutput)) {
                self.captureSession.addOutput(videoFileOutput);
            }
            
            var videoConnection: AVCaptureConnection = videoFileOutput.connectionWithMediaType(AVMediaTypeVideo);
            videoConnection.videoOrientation = videoOrientation;
            
            dispatch_async(delegateCallbackQueue, { [weak self] () -> Void in
                if var blockSelf = self {
                    blockSelf.delegate?.captureVideoRecordingDidUpdateCurrentSession(blockSelf);
                }
            });
        }
    }
    
    private func anyCaptureDevice() -> AVCaptureDevice {
        var devices:[AVCaptureDevice!] = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as [AVCaptureDevice]!;
        
        return devices[0];
    }
    
    //MARK: - internal interface
    
    func startRunning() {
        dispatch_sync(sessionQueue, { [weak self] () -> Void in
            if var blockSelf = self {
                blockSelf.setupCaptureSession();
                blockSelf.captureSession.startRunning();
            }
        });
    }
    
    func stopRunning() {
        dispatch_sync(sessionQueue, { [weak self] () -> Void in
            if var blockSelf = self {
                blockSelf.captureSession.stopRunning();
            }
        });
    }
    
    func startRecording() {
        if url != nil{
            videoFileOutput.startRecordingToOutputFileURL(url, recordingDelegate: self);
        }
    }
    
    func stopRecording() {
        videoFileOutput.stopRecording();
    }
    
    func setDelegate(delegate: SRVideoRecorderDelegate, callbackQueue delegateCallbackQueue:(dispatch_queue_t)) {
        self.delegate = delegate;
        self.delegateCallbackQueue = delegateCallbackQueue;
    }
    
    //MARK: - AVCaptureFileOutputRecordingDelegate
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        NSLog("didStartRecordingToOutputFileAtURL - enter");
        
        dispatch_async(delegateCallbackQueue, { [weak self] () -> Void in
            if var blockSelf = self {
                blockSelf.delegate?.captureVideoRecordingDidStartRecoding(blockSelf);
            }
        });
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        NSLog("didFinishRecordingToOutputFileAtURL - enter");
        dispatch_async(delegateCallbackQueue, {[weak self] () -> Void in
            if var blockSelf = self {
                blockSelf.delegate?.captureVideoRecordingDidStopRecoding(blockSelf, withError: error);
            }
        });
    }
}
