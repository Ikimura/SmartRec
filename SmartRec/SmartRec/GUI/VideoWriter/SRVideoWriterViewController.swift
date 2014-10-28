//
//  SRVideoWriterViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation

class SRVideoWriterViewController: SRCommonViewController, SRVideoCaptureManagerDelegateProtocol {

    @IBOutlet weak var recordBtn: UIButton!
    
    private var recordManager: SRVideoCaptureManager!;
    private var previewView: UIView?;
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        recordManager = SRVideoCaptureManager();
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
    
    //MARK: - private
    
    private func startRecording() {
        NSLog("START RECORDING");
        recordBtn.enabled = false;
        //
        recordManager.startRecording();
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
        recordManager.stopRecording();
        //
        recordBtn.selected = false;
        recordBtn.titleLabel?.text = "Rec";
        
        UIApplication.sharedApplication().idleTimerDisabled = false;
        
        recordBtn.enabled = true;
    }
    
    //MARK - SRVideoRecorderDelegateProtocol
    
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

}
