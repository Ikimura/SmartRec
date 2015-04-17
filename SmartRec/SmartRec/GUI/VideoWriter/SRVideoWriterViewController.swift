//
//  SRVideoWriterViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import CoreMotion

class SRVideoWriterViewController: SRCommonViewController, SRVideoCaptureManagerDelegate {

    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!

    private var recordManager: SRVideoCaptureManager!;
    private var previewView: UIView?;
    private var timer: NSTimer?;
    private var seconds: Int = 0;
    private var locationQueue: dispatch_queue_t?;
    private var acceleraometrWidget: SRGSensor?;

    //MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = true;
        recordManager = SRVideoCaptureManager();
        recordManager.delegate = self;

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication());
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication());
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdatedLocations:", name: kLocationTitleNotification, object: nil)
        
        locationQueue = dispatch_queue_create("con.epam.evnt.SmartRec.locations", DISPATCH_QUEUE_SERIAL);
        
        acceleraometrWidget = SRGSensor(delta: 0.05, frequancy: 1/50, allowView: true);

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        //add constraints
        self.setUpWidgetView();
        
        recordManager.startRunnigSession();
        
        //Update location, speed, timer
        dispatch_async(locationQueue, { [weak self]() -> Void in
            
            if let strongSelf = self {
                
                strongSelf.appDelegate.startMonitoringLocation();
            }
        });
        //start monitoring acceleration
        acceleraometrWidget?.startAccelerationMonitoring();
        
        //FIXME: - fix it
        recordManager.createNewRoute();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        
        recordManager.stopRunnigSession();
        
        //stup location updating
        dispatch_async(locationQueue, { [weak self]() -> Void in
            
            if let strongSelf = self {
                
                strongSelf.appDelegate.stopMonitoringLocation();
            }
        });
        //stop monitoring acceleration
        acceleraometrWidget?.stopAccelerationMonitoring();
        
        //FIXME: - fix it
        recordManager.finishRoute();
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Handlers
    
    @IBAction func recBtnAction(sender: AnyObject) {
        if recordBtn.selected == false {
            self.startRecording();
        } else {
            self.stopRecording();
        }
    }
    
    //MARK: - private methods
    
    private func setUpWidgetView() {
        acceleraometrWidget!.widgetView.setTranslatesAutoresizingMaskIntoConstraints(false);
        
        view.addSubview(acceleraometrWidget!.widgetView);
        let viewsDictionary: [NSObject: AnyObject] = ["widgetView": acceleraometrWidget!.widgetView];
        
        let constraint_POS_V = NSLayoutConstraint.constraintsWithVisualFormat("H:[widgetView]-0-|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary);
        
        let constraint_POS_H = NSLayoutConstraint.constraintsWithVisualFormat("V:|-150-[widgetView]", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary);
        
        view.addConstraints(constraint_POS_V);
        view.addConstraints(constraint_POS_H);
    }
    
    func updateTimeLabel(t: NSTimer) {
        var minutesPast, secondsPast: Int;
        
        seconds++;
        minutesPast = (seconds % 3600) / 60;
        secondsPast = (seconds % 3600) % 60;
        timeLabel.text = String(format: "%02d:%02d", minutesPast, secondsPast);
    }
    
    private func updateUIByDefault() {
        dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
            if var blockSelf = self {
                blockSelf.timeLabel.text = "00:00";
                blockSelf.latitudeLabel.text = "-";
                blockSelf.longitudeLabel.text = "-";
                var time = NSLocalizedString("distance_reduction", comment: "comment");
                var dist = NSLocalizedString("time_hour_reduction", comment: "comment");
                
                blockSelf.speedLabel.text = "0 \(dist)/\(time)";
            }
        });
    }
    
    private func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTimeLabel:", userInfo: nil, repeats: true);
    }
    
    private func stopTimer() {
        seconds = 0;
        timer?.invalidate();
    }
    
    private func startRecording() {
        NSLog("START RECORDING");
        recordBtn.enabled = false;
        //Record video
        recordManager.startRecordingVideo();
        self.startTimer();
        //
        recordBtn.selected = true;
        // Disable the idle timer while recording
        UIApplication.sharedApplication().idleTimerDisabled = true;
        //Start recording
        recordBtn.enabled = true;
    }
    
    private func stopRecording() {
        NSLog("STOP RECORDING");
        recordBtn.enabled = false;
        //
        recordManager.stopRecordingVideo();
        self.stopTimer();

        self.updateUIByDefault();
        //
        recordBtn.selected = false;
        
        UIApplication.sharedApplication().idleTimerDisabled = false;
        
        recordBtn.enabled = true;
    }
    
    //MARK: - SRVideoRecorderDelegateProtocol
    
    func videoCaptureManagerDidEndVideoPartRecording(captureManager: SRVideoCaptureManager) {
        NSLog("videoCaptureManagerDidEndVideoPartRecording - delegate");
        //refresh timer
        seconds = 0;
    }
    
    func videoCaptureManagerDidFinishedRecording(captureManager: SRVideoCaptureManager) {
        NSLog("videoCaptureManagerDidFinishedRecording - delegate");
        dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
            if var blockSelf = self {
                blockSelf.stopRecording();
            }
        });
    }
    
    func videoCaptureManagerWillUpdateCaptureSession() {
        NSLog("videoCaptureManagerWillUpdateCaptureSession - delegate");
        
        if (previewView != nil) {
            
            previewView?.removeFromSuperview();
            previewView = nil;
        }
        
        self.showBusyView();
    }
    
    func videoCaptureManagerDidUpdateCaptureSession(captureSession: AVCaptureSession) {
        NSLog("videoCaptureManagerDidUpdateCaptureSession - delegate");

        if previewView == nil {
        
            var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
            
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            
            var layerRect: CGRect = CGRectMake(self.view.layer.bounds.origin.x, self.view.layer.bounds.origin.y, self.view.layer.bounds.maxX, self.view.layer.bounds.maxY);
            
            previewLayer.bounds = layerRect;
            previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
            
            previewView = UIView();
            previewView?.layer.addSublayer(previewLayer);
            
            view.insertSubview(previewView!, atIndex: 0);
            
            self.hideBusyView();
        }
    }
    
    //MARK: - SRLocationManager notification
    
    func didUpdatedLocations(notification: NSNotification) {
        println("Did recieve location notification");
        
        if let userInfo: [NSObject: AnyObject?] = notification.userInfo as [NSObject: AnyObject?]! {
            if let crnLoc = userInfo["location"] as? CLLocation! {
                println("Did updated current location");
                
                dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
                    if var blockSelf = self {
                        blockSelf.latitudeLabel.text = String(format: "%.8f", crnLoc.coordinate.latitude);
                        blockSelf.longitudeLabel.text = String(format: "%.8f", crnLoc.coordinate.longitude);
                        var time = NSLocalizedString("distance_reduction", comment: "comment");
                        var dist = NSLocalizedString("time_hour_reduction", comment: "comment");
                        blockSelf.speedLabel.text = String(format: "%.1f \(dist)/\(time)", crnLoc.speed * 3.6);
                    }
                });
            }
        }
    }
    
    //MARK: - UIApplication notofocation
    
    func applicationDidEnterBackground() {
        NSLog("applicationDidEnterBackground notif");
        self.stopRecording();
        self.stopTimer();
        
        dispatch_async(locationQueue, { [weak self]() -> Void in
            
            if let strongSlef = self {
                
                strongSlef.appDelegate.stopMonitoringLocation();
            }
        });
        //stop monitoring acceleration
        acceleraometrWidget?.stopAccelerationMonitoring();
    }
    
    func applicationWillEnterForeground() {
        NSLog("applicationWillEnterForeground notif");
        self.updateUIByDefault();
        //start monitoring acceleration
        acceleraometrWidget?.startAccelerationMonitoring();
    }

}
