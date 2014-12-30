//
//  SRVideoRouteDetailsViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/22/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import CoreData

class SRVideoRouteDetailsViewController: SRCommonMapViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var videoFileNameLabel: UILabel!
    @IBOutlet weak var videoMarkLocationLabel: UILabel!
    @IBOutlet weak var videoMarkDateLabel: UILabel!
    @IBOutlet weak var videFileDurationLabel: UILabel!
    @IBOutlet weak var routeStartEndDateLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var videoResolutionLabel: UILabel!
    @IBOutlet weak var videoFrameRateLabel: UILabel!
    
    var route: SRRoute?;
    var selectedVideoId: String?;
    
    private var selectedVideoMark: SRVideoMark?;
    private var videoURL: NSURL?;
    private lazy var geocodingProvider: SRGoogleGeocodingDataProvider = {
        var tempProvider = SRGoogleGeocodingDataProvider();
        return tempProvider;
    }();

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let predicate = NSPredicate(format: "id = %@", selectedVideoId!);
        
        var temMarks = route?.videoMarks.filteredOrderedSetUsingPredicate(predicate!);
        
        var location: CLLocation?;
        if (temMarks != nil) {
            if var temp = temMarks?.firstObject as? SRVideoMark {
                selectedVideoMark = temp;
                location = CLLocation(latitude: selectedVideoMark!.latitude.doubleValue, longitude: selectedVideoMark!.longitude.doubleValue);
            }
        }
        
        self.setUpMapViewWith(location);
        
        self.makePolylineForRoute(route!);
        
        route?.videoMarks.enumerateObjectsUsingBlock { [weak self] (element, index, stop) -> Void in
            if var blockSelf = self {
                if let mark = element as? SRVideoMark {
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        //show annotations
                        println("Id: \(mark.id)");
                        var dic: [String: AnyObject!] = [
                            "id": mark.id,
                            "date": mark.videoData!.date.description,
                            "fileName": mark.videoData!.fileName,
                            "lat": mark.latitude.doubleValue,
                            "lng": mark.longitude.doubleValue,
                            "photo": mark.thumnailImage];
                        //
                        var place: SRVideoPlace = SRVideoPlace(dictionary: dic);
                        
                        var routeMarker = SRRouteMarker(videoPoint: place, routeID: blockSelf.route!.id);
                        
                        blockSelf.showGoogleMapMarker(routeMarker);
                    });
                }
            }
        };
        
        self.updateRouteInformation();
        
        self.updateVideoInformation();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
    }
    
    //MARK: - internal interface
    
    override func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        mapView.selectedMarker = marker;
        
        if let routeMarker = marker as? SRRouteMarker {
            let anchor = marker.position;
            println("Id: \(routeMarker.videoPoint.videoIdentifier)");

            let predicate = NSPredicate(format: "id = %@", routeMarker.videoPoint.videoIdentifier);
            var temp = route?.videoMarks.filteredOrderedSetUsingPredicate(predicate!);
            
            if (temp != nil && temp?.count != 0) {
                selectedVideoMark = temp?.firstObject as? SRVideoMark;
                self.updateVideoInformation();
            } else {
                print("Error!");
            }
        }
        return true;
    }
    
    override func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        //Show video
        if let tempMarker = marker as? SRRouteMarker {
            if let url = NSURL.URL(directoryName: kFileDirectory, fileName: "\(tempMarker.videoPoint.fileName)\(kFileExtension)") as NSURL! {
                videoURL = url;
            }
            self.performSegueWithIdentifier(kShowVideoSegueIdentifier_2, sender: self);
        }
    }
   
    //MARK: - private interface
    
    private func updateRouteInformation() {
        //set route start-end dagte time
        var startDate: NSDate?;
        if let firstPoint = route!.routePoints.firstObject as? SRRoutePoint {
            startDate = NSDate(timeIntervalSince1970: firstPoint.time.doubleValue);
        }
        
        var endDate: NSDate?;
        if let lastPoint = route!.routePoints.lastObject as? SRRoutePoint {
            endDate = NSDate(timeIntervalSince1970: lastPoint.time.doubleValue);
        }
        
        let startDateString = startDate?.stringFromDateWithStringFormat("ccc, LLL d, h:m:s");
        let endDateString = endDate?.stringFromDateWithStringFormat("ccc, LLL d, h:m:s");
        
        routeStartEndDateLabel.text = "\(startDateString!) - \(endDateString!)";
    }
    
    //TDOD: add filed locationDescription in SRVideoMark
    
    private func updateVideoInformation() {
        videoFileNameLabel.text = selectedVideoMark!.videoData!.fileName;
        geocodingProvider.geocoding(selectedVideoMark!.latitude.doubleValue, lng: selectedVideoMark!.longitude.doubleValue) { [weak self] (data) -> Void in
            //parse JSON
            if var blockSelf = self {
                
                //2
                if let json = data as? NSDictionary {
                    if let res  = json["results"] as? NSArray {
                        if let feed = res[1] as? String{
//                            if let address = feed.objectForKey("formatted_address") {
                                println(feed);
//                            }
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //            videoMarkLocationLabel.text = "\(selectedVideoMark!.locationDescription)";
                });
            }
//                if let json = data as? Dictionary {
//                    if let obj = json["formatted_address"][0].stringValue {
//                        println("Print: \(obj)");
//                    }
//                }
        }
        
//        if (selectedVideoMark?.locationDescription == nil) {
//            tempProvider.
//        } else {
//            videoMarkLocationLabel.text = "\(selectedVideoMark!.locationDescription)";
//        }
        //date
        let date: NSDate = NSDate(timeIntervalSince1970: selectedVideoMark!.videoData!.date.doubleValue);
        videoMarkDateLabel.text = date.stringFromDateWithStringFormats([kTimeFormat, kDateFormat, kTimeFormat]);
        //set file duration
        let seconds = selectedVideoMark!.videoData!.duration.doubleValue.format(".1");
        let durationLS = NSLocalizedString("DURATION", comment: "comment");
        videFileDurationLabel.text = "\(durationLS): \(seconds)";
        //set size data bytes
        let mBytes = Double(Double(selectedVideoMark!.videoData!.fileSize.integerValue) / 1000000.0).format(".3");
        let sizeLS = NSLocalizedString("SIZE", comment: "comment");
        fileSizeLabel.text = "\(sizeLS): \(mBytes) MB.";
        //set video resolution
        videoResolutionLabel.text = "\(selectedVideoMark!.videoData!.resolutionWidth.integerValue)x\(selectedVideoMark!.videoData!.resolutionHeight.integerValue)";
        //set frame rates
        let fps = Double(selectedVideoMark!.videoData!.frameRate.floatValue).format(".2");
        videoFrameRateLabel.text = "FPS: \(fps)";
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == kShowVideoSegueIdentifier_2 {
            if let showVideoVC = segue.destinationViewController as? SRShowVideoViewController {
                showVideoVC.fileURL = videoURL!;
            }
        }
    }

    
}
