//
//  SRVideoWriterCapturePipline.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation

protocol SRVideoWriterCapturePipelineDelegate {
    
    func capturePipelinedidStopRunning(capturePipeline: SRVideoWriterCapturePipeline, withError error: NSError) -> Void;
    
    // Preview
//    func capturePipeline(capturePipeline: SRVideoWriterCapturePipeline, previewPixelBufferReadyForDisplay previewPixelBuffer: CVPixelBufferRef) -> Void;
//    func capturePipelineDidRunOutOfPreviewBuffers(capturePipeline: SRVideoWriterCapturePipeline) -> Void;
    
//    // Recording
    func capturePipelineRecordingDidStart(capturePipeline: SRVideoWriterCapturePipeline) -> Void;
    func capturePipelineDidFail(capturePipeline: SRVideoWriterCapturePipeline, withError error: NSError) -> Void;
    func capturePipelineRecordingWillStop(capturePipeline: SRVideoWriterCapturePipeline) -> Void;
    func capturePipelineRecordingDidStop(capturePipeline: SRVideoWriterCapturePipeline) -> Void;
}

class SRVideoWriterCapturePipeline: NSObject {
    var renderingEnabled: Bool!; // When set to false the GPU will not be used after the setRenderingEnabled: call returns.
    var recordingOrientation: AVCaptureVideoOrientation!; // client can set the orientation for the recorded movie
    
    //stats
    var videoFrameRate: Float!;
    var videoDimensions: CMVideoDimensions!;
    
//    __weak id <RosyWriterCapturePipelineDelegate> _delegate; // __weak doesn't actually do anything under non-ARC
//    dispatch_queue_t _delegateCallbackQueue;
//    
//    NSMutableArray *_previousSecondTimestamps;
//    
    var captureSession: AVCaptureSession!;
    var videoDevice: AVCaptureDevice?;
//    AVCaptureConnection *_audioConnection;
//    AVCaptureConnection *_videoConnection;
//    var running: Bool;
//    BOOL _startCaptureSessionOnEnteringForeground;
    var applicationWillEnterForegroundNotificationObserver: AnyObject?;
//
    var sessionQueue: dispatch_queue_t!;
//    dispatch_queue_t _videoDataOutputQueue;
//    
//    id<RosyWriterRenderer> _renderer;
//    BOOL _renderingEnabled;
//    
//    NSURL *_recordingURL;
//    RosyWriterRecordingStatus _recordingStatus;
//    
//    UIBackgroundTaskIdentifier _pipelineRunningTask;
    override init() {
        
        super.init();
    }
    
    internal func setDelegate(delegate: AnyObject?, delegateCallbackQueue:dispatch_queue_t) -> Void {
        
    }
    
    // These methods are synchronous
    func startRunning() {
        
        dispatch_async(sessionQueue, { [unowned self] () -> Void  in
//            self.setupCaptureSession();
            
            self.captureSession.startRunning();
//            self.running = true;
        });
    }
    
    func stopRunning() -> Void {
        
    }
    
    // Must be running before starting recording
    // These methods are asynchronous, see the recording delegate callbacks
    func startRecording() -> Void {
        
    }
    
    func stopRecording() -> Void {
        
    }
    
    //MARK: - private
    func setupCaptureSession () {
        if (captureSession != nil) {
            return;
        }
    
        captureSession = AVCaptureSession();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"captureSessionNotification:", name:nil, object:captureSession);
        
//TODO: FIX
//        applicationWillEnterForegroundNotificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication(), queue: nil, usingBlock: { [unowned self] (note: NSNotification!) -> Void in
//            // Retain self while the capture session is alive by referencing it in this observer block which is tied to the session lifetime
//            // Client must stop us running before we can be deallocated
//            self.applicationWillEnterForeground();
//        });
        
    
//    /* Video */
        var videoDevice: AVCaptureDevice =  AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
        self.videoDevice = videoDevice;
        
        var videoIn: AVCaptureDeviceInput = AVCaptureDeviceInput(device: self.videoDevice, error: nil);
        
        if (self.captureSession.canAddInput(videoIn)) {
            self.captureSession.addInput(videoIn);
        }

        var videoOut: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput();
        
//        var videoSettings: [String: String] = [kCVPixelBufferPixelFormatTypeKey: NSNumber.numberWithUnsignedInt(renderer.inputPixelFormat)];
        
//        videoOut.videoSettings = videoSettings;
//        [videoOut setSampleBufferDelegate:self queue:_videoDataOutputQueue];
//
//    // RosyWriter records videos and we prefer not to have any dropped frames in the video recording.
//    // By setting alwaysDiscardsLateVideoFrames to NO we ensure that minor fluctuations in system load or in our processing time for a given frame won't cause framedrops.
//    // We do however need to ensure that on average we can process frames in realtime.
//    // If we were doing preview only we would probably want to set alwaysDiscardsLateVideoFrames to YES.
//    [videoOut setAlwaysDiscardsLateVideoFrames:NO];
//    
//    if ( [_captureSession canAddOutput:videoOut] ) {
//    [_captureSession addOutput:videoOut];
//    }
//    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
//    
//    int frameRate;
//    NSString *sessionPreset = AVCaptureSessionPresetHigh;
//    CMTime frameDuration = kCMTimeInvalid;
//    // For single core systems like iPhone 4 and iPod Touch 4th Generation we use a lower resolution and framerate to maintain real-time performance.
//    if ( [[NSProcessInfo processInfo] processorCount] == 1 )
//    {
//    if ( [_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480] ) {
//    sessionPreset = AVCaptureSessionPreset640x480;
//    }
//    frameRate = 15;
//    }
//    else
//    {
//    // USE_GPU_RENDERER is set in the project's build settings
//    #if ! USE_GPU_RENDERER
//    // When using the CPU renderer we lower the resolution to 720p so that all devices can maintain real-time performance (this is primarily for A5 based devices like iPhone 4s and iPod Touch 5th Generation).
//    if ( [_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720] ) {
//    sessionPreset = AVCaptureSessionPreset1280x720;
//    }
//    #endif // ! USE_GPU_RENDERER
//    
//    frameRate = 30;
//    }
//    
//    _captureSession.sessionPreset = sessionPreset;
//    
//    frameDuration = CMTimeMake( 1, frameRate );
//    
//    NSError *error = nil;
//    if ( [videoDevice lockForConfiguration:&error] ) {
//    [videoDevice setActiveVideoMaxFrameDuration:frameDuration];
//    [videoDevice setActiveVideoMinFrameDuration:frameDuration];
//    [videoDevice unlockForConfiguration];
//    }
//    else {
//    NSLog(@"videoDevice lockForConfiguration returned error %@", error);
//    }
//    
//    self.videoOrientation = [_videoConnection videoOrientation];
//    
//    [videoOut release];
//    
//    return;
    }
    
//    func transformFromVideoBufferOrientationToOrientation(orientation: AVCaptureVideoOrientation, withAutoMirroring mirroring:Bool) -> CGAffineTransform {
//        
//    }
    
    //TODO: FIX

//    func applicationWillEnterForeground()
//    {
//    NSLog( @"-[%@ %@] called", NSStringFromClass([self class]), NSStringFromSelector(_cmd) );
//    
//    dispatch_sync( _sessionQueue, ^{
//    if ( _startCaptureSessionOnEnteringForeground ) {
//    NSLog( @"-[%@ %@] manually restarting session", NSStringFromClass([self class]), NSStringFromSelector(_cmd) );
//    
//    _startCaptureSessionOnEnteringForeground = NO;
//    if ( _running ) {
//				[_captureSession startRunning];
//    }
//    }
//    } );
//    }
}
