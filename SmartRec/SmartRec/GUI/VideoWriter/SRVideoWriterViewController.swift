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
        
        var filePath = "";
        filePath += documentsDirectory;
        filePath += "my_file.mov";
        
        if (NSFileManager.defaultManager().fileExistsAtPath(filePath))
        {
            var error: NSError?;
            if (NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error) == false)
            {
                //Error - handle if requried
            }
        }
        let outputURL = NSURL(fileURLWithPath: filePath);
        videoRecorder = SRVideoRecorder(wtihURL: outputURL!);
        
        //ADD VIDEO PREVIEW LAYER
        previewLayer = AVCaptureVideoPreviewLayer(session: videoRecorder.captureSession);
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        var layerRect: CGRect = self.view.layer.bounds;
        
        previewLayer.bounds = layerRect;
        previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
        
        //We use this instead so it goes on a layer behind our UI controls (avoids us having to manually bring each control to the front):
        var cameraView: UIView = UIView();
        self.view.insertSubview(cameraView, atIndex: 0);
        cameraView.layer.addSublayer(previewLayer);
        
        self.view.bringSubviewToFront(recordBtn);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        videoRecorder.startRunning();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        videoRecorder.startRecording();
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated);
        videoRecorder.stopRecording();
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

            //Start recording
            videoRecorder.startRecording();
            
        } else {
            videoRecorder.stopRecording();
        }
    }
    
    //MARK: - mathods protected
    
    func recordingStopped() -> Void {

    }

}
