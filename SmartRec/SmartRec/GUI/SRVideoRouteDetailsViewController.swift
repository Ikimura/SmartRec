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
    
    private var selectedVideoMark: SRRouteVideoPoint?;
    private var videoURL: NSURL?;
    private lazy var geocodingProvider: SRGoogleGeocodingDataProvider = {
        var tempProvider = SRGoogleGeocodingDataProvider();
        return tempProvider;
    }();

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var location: CLLocation?;
        if selectedVideoMark != nil {
            let predicate = NSPredicate(format: "id = %@", selectedVideoId!);
            
            var temMarks = route?.videoMarks.filteredOrderedSetUsingPredicate(predicate!);
            
            if (temMarks != nil) {
                if var temp = temMarks?.firstObject as? SRRouteVideoPoint {
                    selectedVideoMark = temp;
                    location = CLLocation(latitude: selectedVideoMark!.latitude.doubleValue, longitude: selectedVideoMark!.longitude.doubleValue);
                }
            }
            self.updateVideoInformation();
        }
        self.setUpMapViewWith(location);
        
        self.makePolylineForRoute(route!);
        
        self.markVideoMarkersForRoute(route!);
        
        self.updateRouteInformation();
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
        
        if let routeMarker = marker as? SRVideoMapMarker {
            let anchor = marker.position;
            println("Id: \(routeMarker.videoPoint.videoIdentifier)");

            let predicate = NSPredicate(format: "id = %@", routeMarker.videoPoint.videoIdentifier);
            var temp = route?.videoMarks.filteredOrderedSetUsingPredicate(predicate!);
            
            if (temp != nil && temp?.count != 0) {
                selectedVideoMark = temp?.firstObject as? SRRouteVideoPoint;
                self.updateVideoInformation();
            } else {
                print("Error!");
            }
        }
        return true;
    }
    
    override func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        //Show video
        if let tempMarker = marker as? SRVideoMapMarker {
            if let url = NSURL.URL(directoryName: kFileDirectory, fileName: "\(tempMarker.videoPoint.fileName)\(kFileExtension)") as NSURL! {
                videoURL = url;
            }
            self.performSegueWithIdentifier(kShowVideoSegueIdentifier_2, sender: self);
        }
    }
    
    override func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView! {
        var mapInfoView = UIView.viewFromNibName("SRSimpleMarkerView") as? SRSimpleMarkerView!;

        if let routeMarker = marker as? SRVideoMapMarker {
            let anchor = marker.position;
            if let photo = routeMarker.videoPoint.photo {
                mapInfoView!.imageView.image = photo;
            }
        }
        
        return mapInfoView
    }
    
    override func prepareItemToShare() {
        if (self.selectedVideoMark != nil) {
            if let itemURL = NSURL.URL(directoryName: kFileDirectory, fileName: "\(selectedVideoMark!.videoData!.fileName)\(kFileExtension)") as NSURL! {
                self.fileURL = itemURL;
                self.shareVideoItem();
            }
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
    
    //TDOD: add filed locationDescription in SRRouteVideoPoint

    private func updateVideoInformation() {
        
        if (selectedVideoMark?.locationDescription == nil) {
            geocodingProvider.geocoding(selectedVideoMark!.latitude.doubleValue, lng: selectedVideoMark!.longitude.doubleValue) { [weak self] (data) -> Void in
                //parse JSON
                if var blockSelf = self {
                    
                    var responseDict: NSDictionary = data as NSDictionary;
                    var results: NSArray = responseDict["results"] as NSArray
                    var item: NSDictionary = results[0] as NSDictionary
                    
                    var googleAddress = item["formatted_address"] as NSString;
                    
                    //location description
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        blockSelf.videoMarkLocationLabel.text = googleAddress;
                    })
                    
                    blockSelf.selectedVideoMark?.locationDescription =  googleAddress;
                    
                    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
                    
                    appDelegate.coreDataManager.updateEntity(blockSelf.selectedVideoMark!);
                }
            }
        } else {
            videoMarkLocationLabel.text = selectedVideoMark!.locationDescription;
        }
        
        videoFileNameLabel.text = selectedVideoMark!.videoData!.fileName;
        
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
                showVideoVC.fileURLToShow = videoURL!;
            }
        }
    }

    
}
