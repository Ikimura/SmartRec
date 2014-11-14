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

class SRVideoWriterViewController: SRCommonViewController, SRVideoCaptureManagerDelegate, SRLocationManagerDelegate, SRAccelerometrManagerDelegate {

    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var accelerationXLabel: UILabel!
    @IBOutlet weak var accelerationYLabel: UILabel!
    @IBOutlet weak var accelerationZLabel: UILabel!

    private var recordManager: SRVideoCaptureManager!;
    private var previewView: UIView?;
    private var timer: NSTimer?;
    private var seconds: Int = 0;
    private var locationQueue: dispatch_queue_t?;

    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        recordManager = SRVideoCaptureManager();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication());
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication());

        locationQueue = dispatch_queue_create("con.epam.evnt.SmartRec.locations", DISPATCH_QUEUE_SERIAL);
        
//        SRLocationManager.sharedInstance.delegate = self;
//        SRAccelerometrManager.sharedInstance.delegate = self;
        recordManager.delegate = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        recordManager.startRunnigSession();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        recordManager.stopRunnigSession();
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: UIApplication.sharedApplication());
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: UIApplication.sharedApplication());
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
    
    func updateTimeLabel(t: NSTimer) {
        var minutesPast, secondsPast: Int;
        
        seconds++;
        minutesPast = (seconds % 3600) / 60;
        secondsPast = (seconds % 3600) % 60;
        timeLabel.text = NSString(format: "%02d:%02d", minutesPast, secondsPast);
    }
    
    private func updateUIByDefault() {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
            self.timeLabel.text = "00:00";
            self.latitudeLabel.text = "-";
            self.longitudeLabel.text = "-";
            self.speedLabel.text = "0 m/s";
            self.accelerationXLabel.text = "X:";
            self.accelerationYLabel.text = "Y:";
            self.accelerationZLabel.text = "Z:";
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
        //Update location, speed, timer
//        dispatch_async(locationQueue, { () -> Void in
//            SRLocationManager.sharedInstance.startMonitoringLocation();
//        });
        self.startTimer();
        //start monitoring acceleration
//        SRAccelerometrManager.sharedInstance.startAccelerationMonitoring(0.2);
        //
        recordBtn.selected = true;
        recordBtn.titleLabel?.text = "Stop";
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
        //
//        dispatch_async(locationQueue, { () -> Void in
//            SRLocationManager.sharedInstance.stopMonitoringLocation();
//        });
        self.stopTimer();
        //stop monitoring acceleration
//        SRAccelerometrManager.sharedInstance.stopAccelerationMonitoring();
        self.updateUIByDefault();
        //
        recordBtn.selected = false;
        recordBtn.titleLabel?.text = "Rec";
        
        UIApplication.sharedApplication().idleTimerDisabled = false;
        
        recordBtn.enabled = true;
    }
    
    //MARK: - SRVideoRecorderDelegateProtocol
    
    func videoCaptureManagerDidEndVideoPartRecording(captureManager: SRVideoCaptureManager) {
        NSLog("videoCaptureManagerDidEndVideoPartRecording - delegate");
        //refresh timer
        seconds = 0;
    }
    
    func videoCaptureManagerCanGetPreviewView(captureSession: AVCaptureSession) {
        NSLog("captureVideoRecordingPreviewView - delegate");

        if previewView == nil {
            
            var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
            
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            
            var layerRect: CGRect = CGRectMake(self.view.layer.bounds.origin.x, self.view.layer.bounds.origin.y, self.view.layer.bounds.maxX, self.view.layer.bounds.maxY);
            
            previewLayer.bounds = layerRect;
            previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
            
            previewView = UIView();
            previewView?.layer.addSublayer(previewLayer);
            
            view.insertSubview(previewView!, atIndex: 0);
        }
    }
    
    //MARK: - SRLocationManagerDelegate
    
    func srlocationManager(manager: SRLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if let crnLoc = locations[locations.count - 1] as? CLLocation {
            //use dispatch get main queue
            dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                self.latitudeLabel.text = NSString(format: "%.8f", crnLoc.coordinate.latitude);
                self.longitudeLabel.text = NSString(format: "%.8f", crnLoc.coordinate.longitude);
                self.speedLabel.text = NSString(format: "%.1f m/s", crnLoc.speed);
            });
        }
    }
    
    //MARK: - UIApplication notofocation
    
    func applicationDidEnterBackground() {
        NSLog("applicationDidEnterBackground notif");
        self.stopRecording();
        dispatch_async(locationQueue, { () -> Void in
            SRLocationManager.sharedInstance.stopMonitoringLocation();
        });
        //stop monitoring acceleration
        SRAccelerometrManager.sharedInstance.stopAccelerationMonitoring();
        self.stopTimer();
        
    }
    
    func applicationWillEnterForeground() {
        NSLog("applicationWillEnterForeground notif");
        self.updateUIByDefault();
    }
    
    //MARK: - SRAccelerometrManagerDelegate
    
    func accelerometrManagerDidUpdateData(accelerometerData: CMAccelerometerData!) {
        var acceleration = accelerometerData.acceleration;
        dispatch_async(dispatch_get_main_queue(), { [unowned self, acceleration] () -> Void in
            self.accelerationXLabel.text = NSString(format: "X:%.8f", acceleration.x);
            self.accelerationYLabel.text = NSString(format: "Y:%.8f", acceleration.y);
            self.accelerationZLabel.text = NSString(format: "Z:%.8f", acceleration.z);
        });

    }

}
