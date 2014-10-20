//
//  SRVideoWriterViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit

class SRVideoWriterViewController: UIViewController, SRVideoWriterCapturePiplineDelegate {
    
    var addedObservers: Bool!;
    var recording: Bool!;
    var backgroundRecordingID: UIBackgroundTaskIdentifier! = 0;
    
    @IBOutlet weak var recordBtn: UIButton!
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    //TODO: trololo
//        self.capturePipeline = [[RosyWriterCapturePipeline alloc] init];
//        [self.capturePipeline setDelegate:self callbackQueue:dispatch_get_main_queue()];
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication());
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication());
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationDidChange", name: UIDeviceOrientationDidChangeNotification, object: UIDevice.currentDevice());
        
        // Keep track of changes to the device orientation so we can update the capture pipeline
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications();
        
        addedObservers = true;
        
        //TODO: trololo
        // the willEnterForeground and didEnterBackground notifications are subsequently used to update _allowedToUseGPU
//        _allowedToUseGPU = ( [[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground );
//        [self.capturePipeline setRenderingEnabled:_allowedToUseGPU];
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        //TODO: trololo

//        [self.capturePipeline startRunning];
        
//        self.labelTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
    }
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated);
    
//    [self.labelTimer invalidate];
//    self.labelTimer = nil;
        //TODO: trololo

//    [self.capturePipeline stopRunning];
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - Handlers
    
    @IBAction func recBtnAction(sender: AnyObject) {
        if recording == true {
            //TODO:
//            [self.capturePipeline stopRecording];
        }
        else
        {
            // Disable the idle timer while recording
            UIApplication.sharedApplication().idleTimerDisabled = true;
            
            // Make sure we have time to finish saving the movie if the app is backgrounded during recording
            if UIDevice.currentDevice().multitaskingSupported {
                backgroundRecordingID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in });
            }
            
            recordBtn.titleLabel?.text = "Strop";
            
            //TODO: fix
//            [self.capturePipeline startRecording];
            
            recording = true;
        }
    }
    
    //MARK: - mathods protected
    
    func recordingStopped() -> Void {
        recording = false;
        recordBtn.titleLabel?.text = "Rec";
        
        UIApplication.sharedApplication().idleTimerDisabled = false;
        UIApplication.sharedApplication().endBackgroundTask(backgroundRecordingID);
        backgroundRecordingID = UIBackgroundTaskInvalid;
    }
    
    func showError(error: NSError) -> Void {
        var alertVC: UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .Alert);
        
        var okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { (action: UIAlertAction!) -> Void in
        };
        
        alertVC.addAction(okAction);
        
        self.presentViewController(alertVC, animated: true) { () -> Void in };
    }
    
    //MARK: - RosyWriterCapturePipelineDelegate
    
    func capturePipelinedidStopRunning(capturePipeline: SRVideoWriterCapturePipline, withError error: NSError) -> Void {
        self.showError(error);
        
        self.recordBtn.titleLabel?.text = "Rec";
    }
    
    func capturePipelineRecordingDidStart(capturePipeline: SRVideoWriterCapturePipline) -> Void {
        
    }
    
    func capturePipeline(capturePipeline: SRVideoWriterCapturePipline, error: NSError) -> Void {
        
    }
    
    func capturePipelineRecordingWillStop(capturePipeline: SRVideoWriterCapturePipline) -> Void {
        
    }
    
    func capturePipelineRecordingDidStop(capturePipeline: SRVideoWriterCapturePipline) -> Void {
        
    }
    
//    - (void)capturePipeline:(RosyWriterCapturePipeline *)capturePipeline didStopRunningWithError:(NSError *)error
//    {
//    [self showError:error];
//    
//    [[self recordButton] setEnabled:NO];
//    }
//    
//    // Preview
//    - (void)capturePipeline:(RosyWriterCapturePipeline *)capturePipeline previewPixelBufferReadyForDisplay:(CVPixelBufferRef)previewPixelBuffer
//    {
//    if ( ! _allowedToUseGPU ) {
//    return;
//    }
//    
//    if ( ! self.previewView ) {
//    [self setupPreviewView];
//    }
//    
//    [self.previewView displayPixelBuffer:previewPixelBuffer];
//    }
//    
//    - (void)capturePipelineDidRunOutOfPreviewBuffers:(RosyWriterCapturePipeline *)capturePipeline
//    {
//    if ( _allowedToUseGPU ) {
//    [self.previewView flushPixelBufferCache];
//    }
//    }
//    
//    // Recording
//    - (void)capturePipelineRecordingDidStart:(RosyWriterCapturePipeline *)capturePipeline
//    {
//    [[self recordButton] setEnabled:YES];
//    }
//    
//    - (void)capturePipelineRecordingWillStop:(RosyWriterCapturePipeline *)capturePipeline
//    {
//    // Disable record button until we are ready to start another recording
//    [[self recordButton] setEnabled:NO];
//    [[self recordButton] setTitle:@"Record"];
//    }
//    
//    - (void)capturePipelineRecordingDidStop:(RosyWriterCapturePipeline *)capturePipeline
//    {
//    [self recordingStopped];
//    }
//    
//    - (void)capturePipeline:(RosyWriterCapturePipeline *)capturePipeline recordingDidFailWithError:(NSError *)error
//    {
//    [self recordingStopped];
//    [self showError:error];
//    }


}
