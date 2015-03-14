//
//  SRRouteMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/13/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import CoreData

class SRRouteMapViewController: SRCommonRouteMapViewController, SRVideoInfoViewDelegate {
    
    var route: SRRoute?;
    var selectedVideoMark: SRRouteVideoPoint?;
    
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
            
            videoInfoView.delegate = self;
            
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        //load data
//        self.loadData();
    }
    
    //MARK: - private interface
    
//    private func loadData() {
//        
//        println("Loading indicator show");
//        self.showBusyView();
//        
//        appDelegate.coreDataManager.fetchEntities(kManagedObjectRoute, withCompletion: { [weak self] (fetchResult: NSAsynchronousFetchResult) -> Void in
//            
//            if var blockSelf = self {
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    println("Loading indicator hide");
//                    blockSelf.hideBusyView();
//                });
//                
//                if ((fetchResult.finalResult) != nil) {
//                    // Update Items
//                    blockSelf.routes = fetchResult.finalResult as [SRRoute]?;
//                    println("Results Count: \(blockSelf.routes?.count)");
//
//                    for route in blockSelf.routes! {
//                        //show route
//                        println("Count of route points: \(route.routePoints.count)");
//                        
//                        dispatch_async(dispatch_get_main_queue(), {() -> Void in
//                            blockSelf.makePolylineForRoute(route);
//                        });
//                        println("Id: \(route.id)");
//                        println("Count of video marks: \(route.videoMarks.count)");
//                        
//                        blockSelf.markVideoMarkersForRoute(route);
//                    }
//                }
//            }
//        });
//    }
    
    //MARK: - GMSMapViewDelegate
    
    override func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        //Show video
        if let tempMarker = marker as? SRVideoMapMarker {
            
            if let url = NSURL.URL(directoryName: kFileDirectory, fileName: "\(tempMarker.videoPoint.fileName)\(kFileExtension)") as NSURL! {
                videoURL = url;
            }
            self.performSegueWithIdentifier(kShowVideoSegueIdentifier_1, sender: self);
        }
    }
    
    override func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if isDetailsViewShowed != true {
            super.mapView(mapView, didTapAtCoordinate: coordinate);
        }
        
        self.showHideDetailsView(false, animated: true);
    }
    
    override func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView! {
        
        if let routeMarker = marker as? SRVideoMapMarker {
            
            let anchor = marker.position;
            
            mapInfoView.titleLabel.text = routeMarker.videoPoint.fileName;
            mapInfoView.subtitleLabel.text = routeMarker.videoPoint.date;
            
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
            var temp = route?.videoMarks.filteredOrderedSetUsingPredicate(predicate!);
            
            if (temp != nil && temp?.count != 0) {
                
                selectedVideoMark = temp?.firstObject as? SRRouteVideoPoint;
                //update info in view
                self.updateVideoInformation();
                
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
        if let firstPoint = route!.routePoints.firstObject as? SRRoutePoint {
            startDate = NSDate(timeIntervalSince1970: firstPoint.time.doubleValue);
        }
        
        var endDate: NSDate?;
        if let lastPoint = route!.routePoints.lastObject as? SRRoutePoint {
            endDate = NSDate(timeIntervalSince1970: lastPoint.time.doubleValue);
        }
        
        let startDateString = startDate?.stringFromDateWithStringFormat("ccc, LLL d, h:m:s");
        let endDateString = endDate?.stringFromDateWithStringFormat("ccc, LLL d, h:m:s");
        
        videoInfoView.routeStartEndDateLabel.text = "\(startDateString!) - \(endDateString!)";
    }
    
    private func updateVideoInformation() {
        
        if (selectedVideoMark?.locationDescription == nil) {
            
            googleServicesProvider.geocoding(selectedVideoMark!.latitude.doubleValue, lng: selectedVideoMark!.longitude.doubleValue) { [weak self] (data) -> Void in
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
                    
                    blockSelf.selectedVideoMark?.locationDescription =  googleAddress;
                    
                    blockSelf.appDelegate.coreDataManager.updateEntity(blockSelf.selectedVideoMark!);
                }
            }
            
        } else {
            
            videoInfoView.videoMarkLocationLabel.text = selectedVideoMark!.locationDescription;
        }
        
        videoInfoView.videoFileNameLabel.text = selectedVideoMark!.videoData!.fileName;
        
        //date
        let date: NSDate = NSDate(timeIntervalSince1970: selectedVideoMark!.videoData!.date.doubleValue);
        videoInfoView.videoMarkDateLabel.text = date.stringFromDateWithStringFormats([kTimeFormat, kDateFormat, kTimeFormat]);
        
        //set file duration
        let seconds = selectedVideoMark!.videoData!.duration.doubleValue.format(".1");
        let durationLS = NSLocalizedString("DURATION", comment: "comment");
        videoInfoView.videFileDurationLabel.text = "\(durationLS): \(seconds)";
        
        //set size data bytes
        let mBytes = Double(Double(selectedVideoMark!.videoData!.fileSize.integerValue) / 1000000.0).format(".3");
        let sizeLS = NSLocalizedString("SIZE", comment: "comment");
        videoInfoView.fileSizeLabel.text = "\(sizeLS): \(mBytes) MB.";
        
        //set video resolution
        videoInfoView.videoResolutionLabel.text = "\(selectedVideoMark!.videoData!.resolutionWidth.integerValue)x\(selectedVideoMark!.videoData!.resolutionHeight.integerValue)";
        
        //set frame rates
        let fps = Double(selectedVideoMark!.videoData!.frameRate.floatValue).format(".2");
        videoInfoView.videoFrameRateLabel.text = "FPS: \(fps)";
    }
    
    //MARK: - SRVideoInfoViewDelegate
    
    func videoInfoViewDidTapShowButton(view: SRVideoInfoView) {
        self.performSegueWithIdentifier("kShowVideoSegueIdentifier_1", sender: self);
    }

    //MARK: - Private
    
    func markVideoMarkersForRoute(route: AnyObject) {
        
        if var tempRoute = route as? SRRoute {
            
            tempRoute.videoMarks.enumerateObjectsUsingBlock { [weak self] (element, index, stop) -> Void in
                
                if let mark = element as? SRRouteVideoPoint {
                    
                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
                        //show annotations
                        var dic: [String: AnyObject!] = [
                            "id": mark.id,
                            "date": mark.videoData!.date.description,
                            "fileName": mark.videoData!.fileName,
                            "lat": mark.latitude.doubleValue,
                            "lng": mark.longitude.doubleValue,
                            "photo": mark.thumnailImage];
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
        
        if var tempRoute = route as? SRRoute {
            
            var gmsPaths: GMSMutablePath = GMSMutablePath();
            
            tempRoute.routePoints.enumerateObjectsUsingBlock {[weak self] (element, index, stop) -> Void in
                
                if var blockSelf = self {
                    
                    if let routePoint = element as? SRRoutePoint {
                        
                        gmsPaths.addCoordinate(CLLocationCoordinate2D(latitude: routePoint.latitude.doubleValue, longitude: routePoint.longitude.doubleValue));
                        //display markers for points
                        blockSelf.showGoogleMapMarker(SRPointMapMarker(routeID: tempRoute.id));
                    }
                }
            };
            
            self.makeRoute(gmsPaths, id: tempRoute.id, strokeWidth: 5, colored: UIColor.blueColor());
        }
    }
    
    func showGoogleMapMarker(marker: SRBaseMapMarker) {
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = mapView;
    }
    
    // MARK: - parent override
    
    override func prepareItemToShare() {
        if (videoURL != nil) {
            self.fileURL = videoURL;
            self.shareVideoItem();
        }
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        
        switch (segue.identifier!) {
            
        case kShowVideoSegueIdentifier_1:
            if let showVideoVC = segue.destinationViewController as? SRShowVideoViewController {
                showVideoVC.fileURLToShow = videoURL!;
            }
        default:
            println("Segue \(segue.identifier)");
        }
    }
}
