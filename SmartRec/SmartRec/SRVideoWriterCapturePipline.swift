//
//  SRVideoWriterCapturePipline.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation

protocol SRVideoWriterCapturePiplineDelegate {
    
    func capturePipelinedidStopRunning(capturePipeline: SRVideoWriterCapturePipline, withError error: NSError) -> Void;
    
    // Preview
//    - (void)capturePipeline:(RosyWriterCapturePipeline *)capturePipeline previewPixelBufferReadyForDisplay:(CVPixelBufferRef)previewPixelBuffer;
//    - (void)capturePipelineDidRunOutOfPreviewBuffers:(RosyWriterCapturePipeline *)capturePipeline;
//    
    
//    // Recording
    func capturePipelineRecordingDidStart(capturePipeline: SRVideoWriterCapturePipline) -> Void;
    func capturePipeline(capturePipeline: SRVideoWriterCapturePipline, error: NSError) -> Void;
    func capturePipelineRecordingWillStop(capturePipeline: SRVideoWriterCapturePipline) -> Void;
    func capturePipelineRecordingDidStop(capturePipeline: SRVideoWriterCapturePipline) -> Void;
}

class SRVideoWriterCapturePipline: NSObject {
    var renderingEnabled: Bool!; // When set to false the GPU will not be used after the setRenderingEnabled: call returns.
    var recordingOrientation: AVCaptureVideoOrientation!; // client can set the orientation for the recorded movie
    
    //stats
    var videoFrameRate: Float!;
    var videoDimensions: CMVideoDimensions!;
    
    func setDelegate(delegate: AnyObject?, delegateCallbackQueue:dispatch_queue_t) -> Void {
        
    }
    
    // These methods are synchronous
    func startRunning() -> Void {
        
    }
    
    func stopRunning() -> Void {
        
    }
    
    // Must be running before starting recording
    // These methods are asynchronous, see the recording delegate callbacks
    func startRecording() -> Void {
        
    }
    
    func stopRecording() -> Void {
        
    }
    
//    func transformFromVideoBufferOrientationToOrientation(orientation: AVCaptureVideoOrientation, withAutoMirroring mirroring:Bool) -> CGAffineTransform {
//        
//    }

}
