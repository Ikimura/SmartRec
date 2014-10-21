//
//  SRVideoWriterViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation

class SRVideoWriterViewController: UIViewController {

    @IBOutlet weak var recordBtn: UIButton!
    var previewLayer: AVCaptureVideoPreviewLayer!;
    var videoRecorder: SRVideoRecorder!;
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create temporary URL to record to
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var documentsDirectory = paths[0] as String
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .MediumStyle;
        dateFormatter.dateStyle = .NoStyle;
        
        let strName: String = dateFormatter.stringFromDate(NSDate());
        
        var filePath = "";
        filePath += documentsDirectory;
        filePath += "/";
        filePath += strName;
        filePath += ".mov"
        var newfilePath = filePath.stringByReplacingOccurrencesOfString(" ", withString: "");
        NSLog(newfilePath);
        
        if (NSFileManager.defaultManager().fileExistsAtPath(newfilePath))
        {
            var error: NSError?;
            if (NSFileManager.defaultManager().removeItemAtPath(newfilePath, error: &error) == false)
            {
                //Error - handle if requried
            }
        }
        let outputURL = NSURL(fileURLWithPath: newfilePath);
        videoRecorder = SRVideoRecorder(wtihURL: outputURL!);
        
        //ADD VIDEO PREVIEW LAYER
        previewLayer = AVCaptureVideoPreviewLayer(session: videoRecorder.captureSession);
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        var layerRect: CGRect = self.view.layer.bounds;
        
        previewLayer.bounds = layerRect;
        previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
        
//        We use this instead so it goes on a layer behind our UI controls (avoids us having to manually bring each control to the front):
        var cameraView: UIView = UIView();
        cameraView.layer.addSublayer(previewLayer);
        self.view.insertSubview(cameraView, atIndex: 0);
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        videoRecorder.startRunning();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated);
    }
    
    deinit {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARKL: - Notifications
    
    func applicationDidEnterBackground() -> Void {

    }
    
    func applicationWillEnterForeground() -> Void {
        
    }

    //MARK: - Handlers
    
    @IBAction func recBtnAction(sender: AnyObject) {
        if recordBtn.selected == false {
            NSLog("START RECORDING");
            recordBtn.selected = true;
            recordBtn.titleLabel?.text = "Stop";
            // Disable the idle timer while recording
            UIApplication.sharedApplication().idleTimerDisabled = true;
            //Start recording
            videoRecorder.startRecording();
            
            
        } else {
            recordBtn.selected = false;
            recordBtn.titleLabel?.text = "Rec";
            UIApplication.sharedApplication().idleTimerDisabled = false;

            videoRecorder.stopRecording();
        }
    }
    
    //MARK: - mathods protected
    
    func recordingStopped() -> Void {

    }

}
