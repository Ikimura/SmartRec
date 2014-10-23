//
//  SRVideoWriterViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation

class SRVideoWriterViewController: SRCommonViewController, SRVideoRecorderDelegate {

    @IBOutlet weak var recordBtn: UIButton!
    var previewLayer: AVCaptureVideoPreviewLayer!;
    var videoRecorder: SRVideoRecorder!;
    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        var filePath = self.makeNewFilePath();
        NSLog(filePath);
        
        let outputURL = NSURL(fileURLWithPath: filePath)!;
        videoRecorder = SRVideoRecorder(URL: outputURL);
        videoRecorder.setDelegate(self, callbackQueue:dispatch_get_main_queue());

        self.preparePreviewLayer();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        videoRecorder.startRunning();
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
    
    //MARK: - SRVideoRecorderDelegate
    
    func captureVideoRecordingDidStartRecoding(captureRecorder: SRVideoRecorder) {
        NSLog("didStartRecordingToOutputFileAtURL - delegate");

    }
    
    func captureVideoRecordingDidStopRecoding(captureRecorder: SRVideoRecorder, withError error: NSError) {
        NSLog("didFinishRecordingToOutputFileAtURL - delegate");
        self.stopRecording();
    }
    
    //MARK: - mathods protected
    
    func preparePreviewLayer() {
        
        //ADD VIDEO PREVIEW LAYER
        previewLayer = AVCaptureVideoPreviewLayer(session: videoRecorder.captureSession);
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        var layerRect: CGRect = CGRectMake(self.view.layer.bounds.origin.x , self.view.layer.bounds.origin.y, self.view.layer.bounds.maxX , self.view.layer.bounds.maxY);
        
        previewLayer.bounds = layerRect;
        previewLayer.position = CGPointMake(CGRectGetMidX(layerRect), CGRectGetMidY(layerRect));
        
        var cameraView: UIView = UIView();
        cameraView.layer.addSublayer(previewLayer);
        self.view.insertSubview(cameraView, atIndex: 0);
    }
    
    func makeNewFilePath() -> String {
        //Create temporary URL to record to
        let paths = NSSearchPathForDirectoriesInDomains(kFileDirectory, .UserDomainMask, true)
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
        
        return filePath.stringByReplacingOccurrencesOfString(" ", withString: "");
    }
    
    func startRecording() {
        NSLog("START RECORDING");
        recordBtn.enabled = false;
        
        videoRecorder.startRecording();
        
        recordBtn.selected = true;
        recordBtn.titleLabel?.text = "Stop";
        // Disable the idle timer while recording
        UIApplication.sharedApplication().idleTimerDisabled = true;
        //Start recording
        recordBtn.enabled = true;
    }
    
    func stopRecording() {
        NSLog("STOP RECORDING");
        recordBtn.enabled = false;
        
        videoRecorder.stopRecording();
        
        recordBtn.selected = false;
        recordBtn.titleLabel?.text = "Rec";
        
        UIApplication.sharedApplication().idleTimerDisabled = false;
        
        recordBtn.enabled = true;
    }

}
