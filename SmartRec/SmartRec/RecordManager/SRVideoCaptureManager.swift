//
//  SRVideoCaptureManager.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/24/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

protocol SRVideoCaptureManagerDelegate {
    func videoCaptureManagerCanGetPreviewView(captureSession: AVCaptureSession);
    func videoCaptureManagerDidEndVideoPartRecording(captureManager: SRVideoCaptureManager);
    func videoCaptureManagerDidFinishedRecording(captureManager: SRVideoCaptureManager);
}

class SRVideoCaptureManager: NSObject, SRVideoRecorderDelegate {
    
    var delegate: SRVideoCaptureManagerDelegate?;
    
    private let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
    private var currentRecorder: SRVideoRecorder!;
    private var isRecording: Bool!;
    private var routeId: String?;
    private var currentURL: NSURL?;
    //FIXME: - fix
    private lazy var currentMarkData: [String: Any] = {
        var tempArray = [String: Any]();

        return tempArray;
    }();
    
    private lazy var currentVideoData: [String: Any] = {
        var tempArray = [String: Any]();

        return tempArray;
    }();
    
    private lazy var currentRouteData: [String: Any] = {
        var tempArray = [String: Any]();

        return tempArray;
    }();
    
    private lazy var locationData: [CLLocationCoordinate2D] = {
        var tempArray = [CLLocationCoordinate2D]();

        return tempArray;
    }();
    
    //MARK: - life cycle
    
    override init(){
        super.init();
        
        isRecording = false;
        
        //firstly init Recorder with capture session
        var duration: Float64 = kVideoDuration;
        var frameRate: Int32 = kHighFramRate;
        var sessionPreset = AVCaptureSessionPreset1280x720;
        var videoOrientation: AVCaptureVideoOrientation = .Portrait;
        
        currentRecorder = SRVideoRecorder(duration: duration, frameRate: frameRate, orientation: videoOrientation);
        currentRecorder.setDelegate(self, callbackQueue:dispatch_get_main_queue());

        //get notifications about position changing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdatedLocations:", name: kLocationTitleNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didOccasionAppears:", name: "Occasion", object: nil);

    }
    
    deinit {
        //delete observer
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    //MARK: - internal interface
    
    //FIXME: - move in route manager that should be contain a logic
    func createNewRoute() {
        let identifier = String.randomString();
        println(identifier);
        self.currentRouteData["id"] = identifier;
    }
    
    func startRecordingVideo() {
        
        let date = NSDate();
        let fileName = String.stringFromDate(date, withFormat: kFileNameFormat);
        let filePath = "\(fileName)\(kFileExtension)";
        
        println(filePath);
        if let outputURL = NSURL.URL(directoryName: kFileDirectory, fileName: filePath) as NSURL! {
            println(outputURL);
            currentURL = outputURL;
            isRecording = true;
            currentRecorder.url = currentURL;
            currentRecorder.startRecording();
        }
        
        self.currentMarkData["id"] = String.randomString();
        
        println(SRLocationManager.sharedInstance.currentLocation()?.coordinate.latitude);
        println(SRLocationManager.sharedInstance.currentLocation()?.coordinate.longitude);

        currentMarkData["lat"] = SRLocationManager.sharedInstance.currentLocation()?.coordinate.latitude;
        currentMarkData["lng"] = SRLocationManager.sharedInstance.currentLocation()?.coordinate.longitude;
        currentMarkData["save"] = false;
        
        self.currentVideoData["id"] = String.randomString();
        currentVideoData["name"] = fileName;
        currentVideoData["date"] = date;
        
        //FIXME: - move in route manager that should be contain a logic
        currentRouteData["date"] = date;
        
        //add object
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {[weak self] () -> Void in
            if var blockSelf = self {
                let route = (blockSelf.appDelegate.coreDataManager.insertEntity(kManagedObjectRoute, dectionaryData: blockSelf.currentRouteData) as? SRRoute);
                
                blockSelf.routeId = route?.id;
            }
        });
    }
    
    func stopRecordingVideo() {
        //clear data
        locationData.removeAll(keepCapacity: false);
        
        isRecording = false;
        currentRecorder.stopRecording();
    }
    
    func startRunnigSession() {
        currentRecorder.startRunning();
    }
    
    func stopRunnigSession() {
        if isRecording == true {
            isRecording = !isRecording;
            currentRecorder.stopRecording();
        }
        currentRecorder.stopRunning();
    }
    
    //MARK: - private methods
    
    private func saveInformation() {
        //add object
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] () -> Void in
            if var blockSelf = self {
                //insert SRVideoMark
                if let videoMark = blockSelf.appDelegate.coreDataManager.insertEntity(kManagedObjectVideoMark, dectionaryData: blockSelf.currentMarkData) as? SRVideoMark {
                    //link SRVideoData with SRVodeoMark
                    blockSelf.appDelegate.coreDataManager.addRelationBetweenVideoData(blockSelf.currentVideoData, andRouteMark: videoMark.id);
                    //link SRVideoMark with SRRoute
                    blockSelf.appDelegate.coreDataManager.addRelationBetweenVideoMark(videoMark, andRute: blockSelf.routeId!);
                }
            }
        });
    }
    
    private func deleteInformation() {
        //FIXME: - move deleting
        let fileManager = NSFileManager.defaultManager();
        var error: NSError?;
        fileManager.removeItemAtURL(currentURL!, error: &error);
        
        if error != nil {
            println("Debug. Deleting failed");
        }
    }
    
    
    //MARK: - SRLocationManager notification
    
    func didUpdatedLocations(notification: NSNotification) {
        println("Did recieve location notification");

        if let userInfo: [NSObject: AnyObject?] = notification.userInfo as [NSObject: AnyObject?]! {
            if let crnLoc = userInfo["location"] as? CLLocation! {
                println("Did updated current location");
                
                println(crnLoc.coordinate.latitude);
                self.locationData.append(crnLoc.coordinate);
            }
        }
    }
    
    func didOccasionAppears(notification: NSNotification) {
        println("Debug. Did recieve occasion notification");
        //mark current record 
        if ((isRecording == true) && ((currentMarkData["save"] as Bool) == false)) {
            currentMarkData["save"] = true;
        }
    }
    
    //MARK - SRVideoRecorderDelegateProtocol
    
    func captureVideoRecordingDidStartRecoding(captureRecorder: SRVideoRecorder) {
        //delete old video part
        NSLog("captureVideoRecordingDidStartRecoding - delegate");
    }
    
    func captureVideoRecordingDidStopRecoding(captureRecorder: SRVideoRecorder, withError error: NSError?) {
        
        if let needToSave = currentMarkData["save"] as? Bool {
            
            if needToSave { //need save video
                println("Debug. Save data");

                //get asset by url
                var thumbnailImage: UIImage?;
                if let sourceAsset = AVAsset.assetWithURL(currentURL!) as? AVAsset {
                    let maxSize: CGSize = CGSizeMake(kThumbnailWidth, kThumbnailHeight);
                    //get thumbnail image
                    thumbnailImage = sourceAsset.thumbnailWithSize(size: maxSize);
                    currentMarkData["image"] = UIImageJPEGRepresentation(thumbnailImage, 1.0);
                }
                //save
                self.saveInformation();

            } else { //delete file instantaneously or add url in list
                println("Debug. Delete file");
                //delete
                self.deleteInformation();
            }
        }        
    
        //
        //start new video part recording
        if isRecording == true {
            NSLog("captureVideoRecordingDidStopRecoding - delegate");
            delegate?.videoCaptureManagerDidEndVideoPartRecording(self);
            
            self.startRecordingVideo();
        } else {
            delegate?.videoCaptureManagerDidFinishedRecording(self);
        }
    }
    
    func captureVideoRecordingPreviewView(captureRecorder: SRVideoRecorder) {
        NSLog("captureVideoRecordingPreviewView");
        delegate?.videoCaptureManagerCanGetPreviewView(currentRecorder.captureSession);
    }
}
