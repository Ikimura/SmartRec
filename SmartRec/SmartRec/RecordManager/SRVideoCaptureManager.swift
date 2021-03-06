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
    
    func videoCaptureManagerDidEndVideoPartRecording(captureManager: SRVideoCaptureManager);
    func videoCaptureManagerDidFinishedRecording(captureManager: SRVideoCaptureManager);
    
    func videoCaptureManagerWillUpdateCaptureSession();
    func videoCaptureManagerDidUpdateCaptureSession(captureSession: AVCaptureSession);
}

class SRVideoCaptureManager: NSObject, SRVideoRecorderDelegate, SRSettingsManagerDelegate {
    
    var delegate: SRVideoCaptureManagerDelegate?;
    
    private let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
    private var settingsManager: SRSettingsManager!;
    private var currentRecorder: SRVideoRecorder?;
    private var isRecording: Bool = false;
    private var needToDeleteRoute: Bool = true;
    private var routeId: String?;
    private lazy var fileManager: NSFileManager = {
        return NSFileManager.defaultManager();
        }();

    private var currentVideoData: SRVideoDataStruct?;
    private var currentVideoMarkData: SRVideoMarkStruct?;
    private var currentRouteData: SRRouteStruct?;
    private var currentRoutePointData: SRRoutePointStruct?;
    private var previousPoint: CLLocationCoordinate2D?;
    //MARK: - life cycle
    
    override init(){
        super.init();
        
        settingsManager = SRSettingsManager();
        settingsManager.delegate = self;
        
        //firstly init Recorder with capture session
        self.setUpRecorder();

        //get notifications about position changing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didUpdatedLocations:", name: kLocationTitleNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didOccasionAppears:", name: "SROccasionNotification", object: nil);
    }
    
    deinit {
        //delete observer
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    //MARK: - internal interface
    
    //FIXME: - move in route manager that should be contain this logic
    func createNewRoute() {
        
        let identifier = String.randomString();
        println(identifier);
        
        currentRouteData = SRRouteStruct(id: identifier, dateSeconds: NSDate().timeIntervalSince1970, mode:"Driving");
        
        //add object
        SRRoutesController.sharedInstance.insertRouteEntity(self.currentRouteData!, complitionBlock: { [weak self](routeId) -> Void in
            
            if let strongSelf = self {
                
                strongSelf.routeId = routeId;
            }
        });
    }

    func finishRoute() {
        
        if (needToDeleteRoute) {
            
            if (self.routeId != nil) {
                
                SRRoutesController.sharedInstance.deleteRouteWithId(self.routeId!, complitionBlock: { (result) -> Void in
                    println("Delete route resulft: \(result)");
                });
            }
        }
    }
    
    private func addNewRoutePoint(point: SRRoutePointStruct) {
        println("Debug: Add new point");
        
        //link point with route
        SRRoutesController.sharedInstance.addRelationBetweenRoutePoint(point, andRoute: self.routeId!, complitionBlock: { (result) -> Void in
            
            println("addRelationBetweenRoutePoint resulft: \(result)");
        });
    }
    
    //MARK:- inerface
    
    func startRecordingVideo() {
        
        let date = NSDate();
        let fileName = String.stringFromDate(date, withFormat: kFileNameFormat);
        let filePath = "\(fileName)\(kFileExtension)";
        
        currentVideoData = SRVideoDataStruct(id: String.randomString(), fileName: fileName, dateSeconds: date.timeIntervalSince1970);

        //create route point
        currentRoutePointData = SRRoutePointStruct(id: String.randomString(),
            lng: appDelegate.currentLocation().coordinate.longitude,
            lat: appDelegate.currentLocation().coordinate.latitude,
            time: date.timeIntervalSince1970,
            longDescription: nil
        );
        
        //need link route point with route
        self.addNewRoutePoint(currentRoutePointData!);

        println("Debug. New data: \(currentVideoData!.fileName)\(kFileExtension)");
        
        if let outputURL = NSURL.URL(directoryName: kFileDirectory, fileName: filePath) as NSURL! {
            println(outputURL);
            isRecording = true;
            currentRecorder?.url = outputURL;
            currentRecorder?.startRecording();
        }
        
        println(appDelegate.currentLocation().coordinate.latitude);
        println(appDelegate.currentLocation().coordinate.longitude);
        
        currentVideoMarkData = SRVideoMarkStruct(id: String.randomString(),
            lng: appDelegate.currentLocation().coordinate.longitude,
            lat: appDelegate.currentLocation().coordinate.latitude,
            autoSave: false,
            image: nil
        );
    }
    
    func stopRecordingVideo() {
        isRecording = false;
        currentRecorder?.stopRecording();
    }
    
    func startRunnigSession() {
        currentRecorder?.startRunning();
    }
    
    func stopRunnigSession() {
        
        if (isRecording) {
            
            isRecording = !isRecording;
            currentRecorder?.stopRecording();
        }
        currentRecorder?.stopRunning();
    }
    
    //MARK: - private methods
    
    private func setUpRecorder() {
        
        if(currentRecorder != nil) {
            currentRecorder = nil;
        }
        
        var duration: Float64 = settingsManager.videoDuration.doubleValue;
        var frameRate: Int32 = settingsManager.frameRate.intValue;
        var sessionPreset = SRVideoQuality(rawValue: settingsManager.videoQuality.intValue)!;
        var videoOrientation: AVCaptureVideoOrientation = .Portrait;
        
        currentRecorder = SRVideoRecorder(duration: duration, frameRate: frameRate, quality: sessionPreset,  orientation: videoOrientation);
        currentRecorder?.setDelegate(self, callbackQueue:dispatch_get_main_queue());
    }
    
    private func prepareVideoData(videoAsset: AVAsset) {
        var thumbnailImage: UIImage?;
        //image
        let maxSize: CGSize = CGSizeMake(kThumbnailWidth, kThumbnailHeight);
        //get thumbnail image
        thumbnailImage = videoAsset.thumbnailWithSize(size: maxSize);
        currentVideoMarkData!.image = UIImageJPEGRepresentation(thumbnailImage, 1.0);
        //duration
        currentVideoData!.duration = CMTimeGetSeconds(videoAsset.duration);
        //frameRate
        var fps: Float = 0.0;
        var size: CGSize?;
        if let videoATrack: AVAssetTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).last as? AVAssetTrack {
            fps = videoATrack.nominalFrameRate;
            currentVideoData!.frameRate = fps;
            println("\(currentVideoData!.frameRate)")
            //videoresolution
            size = videoATrack.naturalSize;
            currentVideoData!.resHeight = Int32(size!.height);
            currentVideoData!.resWidth = Int32(size!.width);
            println("\(currentVideoData!.resHeight)x\(currentVideoData!.resWidth)")
            //size in butes
            currentVideoData!.fileSize = videoATrack.totalSampleDataLength;
            println("\(currentVideoData!.fileSize)")
        }
    }
    
    private func saveInformationInCoreData(videoData: SRVideoDataStruct, markData: SRVideoMarkStruct) {
        //add object
        println("For save data: \(videoData.fileName)");

        needToDeleteRoute = false;
        
        //insert SRVideoMark and link SRCoreDataRouteVideoPoint with SRCoreDataRoute
        SRRoutesController.sharedInstance.addRelationBetweenRoutePoint(markData, andRoute: self.routeId!, complitionBlock: { (result) -> Void in
            
            println("addRelationBetweenRoutePoint resulft: \(result)");
        });
        
        //link SRCoreDataVideoData with SRVodeoMark
        SRRoutesController.sharedInstance.addRelationBetweenVideoData(videoData, andRouteMark: markData.id, complitionBlock: { (result) -> Void in
            
            println("addRelationBetweenVideoData resulft: \(result)");
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
    
    //MARK: - SRSettingsManagerDelegate

    func settingsDidChange() {
        
        if (currentRecorder?.isRunning == true || currentRecorder?.isInterrupted == true ) {
            
            self.stopRunnigSession();
            
            self.setUpRecorder();
            
            self.startRunnigSession();
            
        } else {
            self.setUpRecorder();
        }
    }
    
    //MARK: - SRLocationManager notification
    
    func didUpdatedLocations(notification: NSNotification) {
        println("Did recieve location notification");

        if (isRecording) {
            
            if let userInfo: [NSObject: AnyObject?] = notification.userInfo as [NSObject: AnyObject?]! {
                
                if let crnLoc = userInfo["location"] as? CLLocation! {
                    println("Did updated current location");

                    if (previousPoint == nil) {
                        
                        previousPoint = CLLocationCoordinate2D(latitude: crnLoc.coordinate.latitude, longitude: crnLoc.coordinate.longitude);
                        
                    } else if (crnLoc.coordinate.latitude != previousPoint!.latitude && crnLoc.coordinate.longitude != previousPoint!.longitude) {
                            
                        //FXME:- move in manager
                        self.addNewRoutePoint(SRRoutePointStruct(id: String.randomString(),
                            lng: crnLoc.coordinate.longitude,
                            lat: crnLoc.coordinate.latitude,
                            time: NSDate().timeIntervalSince1970,
                            longDescription: nil
                            ));
                        
                        previousPoint = crnLoc!.coordinate;
                        
                    }
                }
            }
        }
    }
    
    func didOccasionAppears(notification: NSNotification) {
        println("Debug. Did recieve occasion notification");
        //mark current record 
        if (isRecording && !currentVideoMarkData!.autoSave) {
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
            if let urlForAsset = NSURL.URL(directoryName: kFileDirectory, fileName: "\(currentVideoData!.fileName)\(kFileExtension)") as NSURL! {
                if let sourceAsset = AVAsset.assetWithURL(urlForAsset) as? AVAsset {
                    self.prepareVideoData(sourceAsset);
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
        if (isRecording) {
            
            println("captureVideoRecordingDidStopRecoding - delegate");
            delegate?.videoCaptureManagerDidEndVideoPartRecording(self);
            
            self.startRecordingVideo();
        } else {
            delegate?.videoCaptureManagerDidFinishedRecording(self);
        }
    }
    
    func captureVideoRecordingWillUpdateCurrentSession(captureRecorder: SRVideoRecorder) {
        println("captureVideoRecordingWillUpdateCurrentSession");
        delegate?.videoCaptureManagerWillUpdateCaptureSession();
    }
    
    func captureVideoRecordingDidUpdateCurrentSession(captureRecorder: SRVideoRecorder) {
        println("captureVideoRecordingDidStartRunnigSession");
        delegate?.videoCaptureManagerDidUpdateCaptureSession(currentRecorder!.captureSession);
    }
}
