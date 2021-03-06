//
//  SRRouteMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/13/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import CoreData

class SRRouteMapViewController: SRCommonRouteMapViewController {
    
    var route: SRCoreDataRoute?;
    var selectedVideoMark: SRCoreDataRouteVideoPoint?;
    
    private var videoURL: NSURL?;
    private var videoInfoViewTopLayoutConstraing: NSLayoutConstraint?;
    private var isDetailsViewShowed: Bool = false;

    private lazy var mapInfoView: SRMarkerInfoView! = {
        if let infoView = UIView.viewFromNibName("SRMarkerInfoView") as? SRMarkerInfoView!  {
            
            return infoView;
        } else {
            
            return nil;
        }
    }();
    
    private lazy var videoInfoView: SRVideoInfoView! = {
        
        if let videoInfoView = UIView.viewFromNibName("SRVideoInfoView") as? SRVideoInfoView!  {
            
            return videoInfoView;
        } else {
            return nil;
        }
    }();
    
    private lazy var googleServicesProvider: SRGoogleServicesDataProvider = {
        var tempProvider = SRGoogleServicesDataProvider();
        return tempProvider;
    }();
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup Map
        self.setUpMap(appDelegate.currentLocation().coordinate);
        self.setUpVideoInfoView();
        
        self.makePolylineForRoute(route!);
        
        //update url for sharing
        if let url = NSURL.URL(directoryName: kFileDirectory, fileName: "\(selectedVideoMark!.videoData!.fileName)\(kFileExtension)") as NSURL! {
            
            videoURL = url;
            println("update video url")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
    }
    
    
    //MARK: - GMSMapViewDelegate
    
    override func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        //Show video
        if let tempMarker = marker as? SRVideoMapMarker {
            
            if let url = NSURL.URL(directoryName: kFileDirectory, fileName: "\(tempMarker.videoPoint.fileName)\(kFileExtension)") as NSURL! {
                videoURL = url;
            }
            self.performSegueWithIdentifier(kShowVideoSegueIdentifier, sender: self);
        }
    }
    
    override func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        if (isDetailsViewShowed) {
            
            self.showHideDetailsView(!isDetailsViewShowed, animated: true);

        } else {
            
            super.mapView(mapView, didTapAtCoordinate: coordinate);
        }
    }
    
    override func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView! {
        
        if let routeMarker = marker as? SRVideoMapMarker {
            
            let anchor = marker.position;
            
            mapInfoView.titleLabel.text = routeMarker.videoPoint.fileName;
            let mBytes = Double(Double(selectedVideoMark!.videoData!.fileSize) / 1000000.0).format(".3");
            let mbString = NSLocalizedString("megabytes_title_short", comment: "");
            mapInfoView.subtitleLabel.text = "\(mBytes) \(mbString).";
            if let photo = routeMarker.videoPoint.photo {
                mapInfoView.pictureImageView.image = photo;
            }
        }
        
        return mapInfoView;
    }
    
    override func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        
        mapView.selectedMarker = marker;
        
        if let routeMarker = marker as? SRVideoMapMarker {
            
            let anchor = marker.position;
            println("Id: \(routeMarker.videoPoint.videoIdentifier)");
            
            let predicate = NSPredicate(format: "id = %@", routeMarker.videoPoint.videoIdentifier);
            var temp = route?.videoPoints.filteredOrderedSetUsingPredicate(predicate!);
            
            if (temp != nil && temp?.count != 0) {
                
                selectedVideoMark = temp?.firstObject as? SRCoreDataRouteVideoPoint;
                
                //update url for sharing
                if let url = NSURL.URL(directoryName: kFileDirectory, fileName: "\(selectedVideoMark!.videoData!.fileName)\(kFileExtension)") as NSURL! {
                    
                    videoURL = url;
                    println("update video url")
                }
                
                //update info in view
                self.updateVideoInformation();
                //update route inof
                self.updateRouteInformation();
                
                //show view
                self.showHideDetailsView(true, animated: true);
                
            } else {
                
                print("Error!");
            }
        }
        
        return true;
    }
    
    //MARK: - Info view
    
    private func setUpVideoInfoView() {
        
        videoInfoView.setTranslatesAutoresizingMaskIntoConstraints(false);
        
        mapView.addSubview(self.videoInfoView);
        
        var leadingConstraint = NSLayoutConstraint(item: videoInfoView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: mapView,
            attribute: .Leading,
            multiplier: 1,
            constant: 0);
        
        mapView.addConstraint(leadingConstraint)
        
        var trailingConstraint = NSLayoutConstraint(item: videoInfoView,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: mapView,
            attribute: .Trailing,
            multiplier: 1,
            constant: 0);
        
        mapView.addConstraint(trailingConstraint)
        
        videoInfoViewTopLayoutConstraing = NSLayoutConstraint(item: videoInfoView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: mapView,
            attribute: .Top,
            multiplier: 1,
            constant: 0);
        
        mapView.addConstraint(videoInfoViewTopLayoutConstraing!)
        
        self.showHideDetailsView(false, animated: false);
    }
    
    private func showHideDetailsView(show: Bool, animated: Bool) {
        
        if (animated == true) {
            
            self.view.layoutIfNeeded();
            
            videoInfoViewTopLayoutConstraing!.constant = show == true ? 0 : -(videoInfoView.frame.size.height + kNavigationBarHeight);
            isDetailsViewShowed = show;
            
            UIView.animateWithDuration(0.33, animations: { [weak self]() -> Void in
                if var strongSelf = self {
                    strongSelf.view.layoutIfNeeded();
                }
            });
            
        } else {
            
            videoInfoViewTopLayoutConstraing!.constant = show == true ? 0 : -(videoInfoView.frame.size.height + kNavigationBarHeight);
            isDetailsViewShowed = show;
        }
    }
    
    private func updateRouteInformation() {
        //set route start-end dagte time
        var startDate: NSDate?;
        if let firstPoint = route!.routePoints.firstObject as? SRCoreDataRoutePoint {
            startDate = NSDate(timeIntervalSince1970: firstPoint.time);
        }
        
        var endDate: NSDate?;
        if let lastPoint = route!.routePoints.lastObject as? SRCoreDataRoutePoint {
            endDate = NSDate(timeIntervalSince1970: lastPoint.time);
        }
        
        let startDateString = startDate?.stringFromDateWithStringFormat("ccc, LLL d, h:m:s");
        let endDateString = endDate?.stringFromDateWithStringFormat("ccc, LLL d, h:m:s");
        
        videoInfoView.routeStartEndDateLabel.text = "\(startDateString!) - \(endDateString!)";
    }
    
    private func updateVideoInformation() {
        
        if (selectedVideoMark?.locationDescription == nil) {
            
            googleServicesProvider.geocoding(selectedVideoMark!.latitude, lng: selectedVideoMark!.longitude) { [weak self] (data) -> Void in
                //parse JSON
                if var blockSelf = self {
                    
                    var responseDict: NSDictionary = data as NSDictionary;
                    var results: NSArray = responseDict["results"] as NSArray
                    var item: NSDictionary = results[0] as NSDictionary
                    
                    var googleAddress = item["formatted_address"] as NSString;
                    
                    //location description
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        blockSelf.videoInfoView.videoMarkLocationLabel.text = googleAddress;
                    })
                    
                    blockSelf.selectedVideoMark?.locationDescription =  googleAddress.capitalizedString;
                    
                    SRCoreDataManager.sharedInstance.updateEntity(blockSelf.selectedVideoMark!);
                }
            }
            
        } else {
            
            videoInfoView.videoMarkLocationLabel.text = selectedVideoMark!.locationDescription;
        }
        
        videoInfoView.videoFileNameLabel.text = selectedVideoMark!.videoData!.fileName;
        
        //date
        let date: NSDate = NSDate(timeIntervalSince1970: selectedVideoMark!.videoData!.date);
        videoInfoView.videoMarkDateLabel.text = date.stringFromDateWithStringFormats([kTimeFormat, kDateFormat, kTimeFormat]);
        
        //set file duration
        let seconds = selectedVideoMark!.videoData!.duration.format(".1");
        let durationLS = NSLocalizedString("duration_title", comment: "comment");
        videoInfoView.videFileDurationLabel.text = "\(durationLS.capitalizedString): \(seconds)";
        
        //set size data bytes
        let mBytes = Double(Double(selectedVideoMark!.videoData!.fileSize) / 1000000.0).format(".3");
        let sizeLS = NSLocalizedString("size_title", comment: "");
        let mbString = NSLocalizedString("megabytes_title_short", comment: "");
        videoInfoView.fileSizeLabel.text = "\(sizeLS.capitalizedString): \(mBytes) \(mbString).";
        
        //set video resolution
        videoInfoView.videoResolutionLabel.text = "\(selectedVideoMark!.videoData!.resolutionWidth)x\(selectedVideoMark!.videoData!.resolutionHeight)";
        
        //set frame rates
        let fps = Double(selectedVideoMark!.videoData!.frameRate).format(".2");
        videoInfoView.videoFrameRateLabel.text = "FPS: \(fps)";
    }

    //MARK: - Private
    
    func markVideoMarkersForRoute(route: AnyObject) {
        
        if var tempRoute = route as? SRCoreDataRoute {
            
            tempRoute.videoPoints.enumerateObjectsUsingBlock { [weak self] (element, index, stop) -> Void in
                
                if let mark = element as? SRCoreDataRouteVideoPoint {
                    
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        //show annotations
                        var dic: [String: AnyObject!] = [
                            "id": mark.id,
                            "date": mark.videoData!.date.description,
                            "fileName": mark.videoData!.fileName,
                            "lat": mark.latitude,
                            "lng": mark.longitude,
                            "photo": mark.thumbnailImage];
                        //
                        var place: SRVideoPlace = SRVideoPlace(dictionary: dic);
                        
                        var routeMarker = SRVideoMapMarker(videoPoint: place, routeID: route.id);
                        
                        if var blockSelf = self {
                            blockSelf.showGoogleMapMarker(routeMarker);
                        }
                    });
                }
            };
        }
    }
    
    func makePolylineForRoute(route: AnyObject){
        
        if var tempRoute = route as? SRCoreDataRoute {
            
            var gmsPaths: GMSMutablePath = GMSMutablePath();
            
            tempRoute.routePoints.enumerateObjectsUsingBlock {[weak self] (element, index, stop) -> Void in
                
                if var blockSelf = self {

                    if let routePoint = element as? SRCoreDataRoutePoint {
                        
                        gmsPaths.addCoordinate(CLLocationCoordinate2D(latitude: routePoint.latitude, longitude: routePoint.longitude));
                        //display markers for points
                        blockSelf.showGoogleMapMarker(SRPointMapMarker(routeID: tempRoute.id));
                    }
                }
            };
            
            self.makeRoute(gmsPaths, id: tempRoute.id, strokeWidth: 5, colored: UIColor.blueColor());
            self.markVideoMarkersForRoute(tempRoute);
        }
    }
    
    func showGoogleMapMarker(marker: SRBaseMapMarker) {
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = mapView;
    }
    
    // MARK: - parent override
    
    override func prepareItemToShare() {
        
        if (videoURL != nil) {
            
            self.shareItemWithAirDropSocialServices(videoURL!);   
        }
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        
        switch (segue.identifier!) {
            
        case kShowVideoSegueIdentifier:
            
            if let showVideoVC = segue.destinationViewController as? SRShowVideoViewController {
                showVideoVC.fileURLToShow = videoURL!;
            }
        default:
            println("Segue \(segue.identifier)");
        }
    }
}
