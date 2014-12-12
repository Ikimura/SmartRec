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
    private lazy var fileManager: NSFileManager = {
        return NSFileManager.defaultManager();
        }();

    private var currentVideoData: SRVideoDataStruct?;
    private var currentVideoMarkData: SRVideoMarkStruct?;
    private var currentRouteData: SRRouteStruct?;
    
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
        
        currentRouteData = SRRouteStruct(id: identifier, dateSeconds: NSDate().timeIntervalSince1970);
    }
    
    func startRecordingVideo() {
        let date = NSDate();
        let fileName = String.stringFromDate(date, withFormat: kFileNameFormat);
        let filePath = "\(fileName)\(kFileExtension)";
        
        currentVideoData = SRVideoDataStruct(id: String.randomString(), fileName: fileName, dateSeconds: date.timeIntervalSince1970);

        println("Debug. New data: \(currentVideoData!.fileName)\(kFileExtension)");
        
        if let outputURL = NSURL.URL(directoryName: kFileDirectory, fileName: filePath) as NSURL! {
            println(outputURL);
            isRecording = true;
            currentRecorder.url = outputURL;
            currentRecorder.startRecording();
        }
        
        println(SRLocationManager.sharedInstance.currentLocation()?.coordinate.latitude);
        println(SRLocationManager.sharedInstance.currentLocation()?.coordinate.longitude);
        
        currentVideoMarkData = SRVideoMarkStruct(id: String.randomString(),
            lng: SRLocationManager.sharedInstance.currentLocation()!.coordinate.longitude,
            lat: SRLocationManager.sharedInstance.currentLocation()!.coordinate.latitude,
            autoSave: false,
            image: nil
        );
        
        //add object
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {[weak self] () -> Void in
            if var blockSelf = self {
                let route = (blockSelf.appDelegate.coreDataManager.insertRouteEntity(blockSelf.currentRouteData!) as? SRRoute);
                
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
    
    private func saveInformationInCoreData(videoData: SRVideoDataStruct, markData: SRVideoMarkStruct) {
        //add object
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] () -> Void in
            if var blockSelf = self {
                //insert SRVideoMark
                if let videoMark = blockSelf.appDelegate.coreDataManager.insertVideoMarkEntity(markData) as? SRVideoMark {
                    println("For save data: \(videoData.fileName)");
//                    link SRVideoData with SRVodeoMark
                    blockSelf.appDelegate.coreDataManager.addRelationBetweenVideoData(videoData, andRouteMark: videoMark.id);
//                    link SRVideoMark with SRRoute
                    blockSelf.appDelegate.coreDataManager.addRelationBetweenVideoMark(videoMark, andRute: blockSelf.routeId!);
                }
            }
        });
    }
    
    private func deleteFileFromDisc(fileName: String) {
        let result = self.fileManager.removeItemWithURL(NSURL.URL(directoryName: kFileDirectory, fileName: fileName)!);
        
        switch result {
        case .Success(let quotient):
            println("Debug. File deleted!");
        case .Failure(let error):
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
        if (isRecording == true && !currentVideoMarkData!.autoSave) {
            currentVideoMarkData!.autoSave = true;
        }
    }
    
    //MARK - SRVideoRecorderDelegateProtocol
    
    func captureVideoRecordingDidStartRecoding(captureRecorder: SRVideoRecorder) {
        //delete old video part
        NSLog("captureVideoRecordingDidStartRecoding - delegate");
    }
    
    func captureVideoRecordingDidStopRecoding(captureRecorder: SRVideoRecorder, withError error: NSError?) {
        if currentVideoMarkData!.autoSave { //need save video
            println("Debug. Save file");
            
            //get asset by url
            var thumbnailImage: UIImage?;
            
            if let urlForAsset = NSURL.URL(directoryName: kFileDirectory, fileName: "\(currentVideoData!.fileName)\(kFileExtension)") as NSURL! {
                if let sourceAsset = AVAsset.assetWithURL(urlForAsset) as? AVAsset {
                    let maxSize: CGSize = CGSizeMake(kThumbnailWidth, kThumbnailHeight);
                    //get thumbnail image
                    thumbnailImage = sourceAsset.thumbnailWithSize(size: maxSize);
                    currentVideoMarkData!.image = UIImageJPEGRepresentation(thumbnailImage, 1.0);
                }
            }
            //save
            self.saveInformationInCoreData(currentVideoData!, markData: currentVideoMarkData!);

        } else { //delete file instantaneously or add url in list
            println("Debug. Delete file: \(currentVideoData!.fileName)\(kFileExtension)");
            //delete
            self.deleteFileFromDisc("\(currentVideoData!.fileName)\(kFileExtension)");
        }
    
        //
        //start new video part recording
        if isRecording == true {
            println("captureVideoRecordingDidStopRecoding - delegate");
            delegate?.videoCaptureManagerDidEndVideoPartRecording(self);
            
            self.startRecordingVideo();
        } else {
            delegate?.videoCaptureManagerDidFinishedRecording(self);
        }
    }
    
    func captureVideoRecordingPreviewView(captureRecorder: SRVideoRecorder) {
        println("captureVideoRecordingPreviewView");
        delegate?.videoCaptureManagerCanGetPreviewView(currentRecorder.captureSession);
    }
}
