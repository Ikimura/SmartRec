//
//  SRRouteMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/13/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import CoreData

class SRRouteMapViewController: SRCommonMapViewController {
    
    private var routes: [SRRoute]?;
    private var selectedRoute: SRRoute?;
    private var selectedVideoMarkId: String?;
    private var videoURL: NSURL?;
    private lazy var mapInfoView: SRMarkerInfoView! = {
        if let infoView = UIView.viewFromNibName("SRMarkerInfoView") as? SRMarkerInfoView!  {
            return infoView;
        } else {
            return nil;
        }
    }();
        
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setup Map
        self.setUpMapViewWith(SRLocationManager.sharedInstance.currentLocation() as CLLocation?);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        //load data
        self.loadData();
    }
    
    //MARK: - private interface
    
    private func loadData() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        println("Loading indicator show");
        self.showBusyView();
        
        appDelegate.coreDataManager.fetchEntities(kManagedObjectRoute, withCompletion: { [weak self] (fetchResult: NSAsynchronousFetchResult) -> Void in
            
            if var blockSelf = self {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    println("Loading indicator hide");
                    blockSelf.hideBusyView();
                });
                
                if ((fetchResult.finalResult) != nil) {
                    // Update Items
                    blockSelf.routes = fetchResult.finalResult as [SRRoute]?;
                    println("Results Count: \(blockSelf.routes?.count)");

                    for route in blockSelf.routes! {
                        //show route
                        println("Count of route points: \(route.routePoints.count)");
                        
                        dispatch_async(dispatch_get_main_queue(), {() -> Void in
                            blockSelf.makePolylineForRoute(route);
                        });
                        println("Id: \(route.id)");
                        println("Count of video marks: \(route.videoMarks.count)");
                        
                        route.videoMarks.enumerateObjectsUsingBlock { (element, index, stop) -> Void in
                            if let mark = element as? SRVideoMark {
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
                                    
                                    var routeMarker = SRRouteMarker(videoPoint: place, routeID: route.id);
                                    
                                    blockSelf.showGoogleMapMarker(routeMarker);
                                });
                            }
                        };
                    }
                }
            }
        });
    }

    //TODO: - move in route line tap handler
    //            var temp = routes?.filter({ (r: SRRoute) -> Bool in
    //                return r.id == tempMarker.routeID;
    //            });
    //            selectedRoute = temp?.first;
    //            selectedVideoMarkId = tempMarker.videoPoint.videoIdentifier;
    //
    
    //MARK: - GMSMapViewDelegate
    
    override func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        //Show video
        if let tempMarker = marker as? SRRouteMarker {
            if let url = NSURL.URL(directoryName: kFileDirectory, fileName: "\(tempMarker.videoPoint.fileName)\(kFileExtension)") as NSURL! {
                videoURL = url;
            }
            self.performSegueWithIdentifier(kShowVideoSegueIdentifier_1, sender: self);
        }
    }
    
    //FIXME: - fix
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    // Get the new view controller using segue.destinationViewController.
//        if segue.identifier == kDisplayVideoRouteDetailsSegueIdentifier_2 {
//            if let routeVideoDetailsVC = segue.destinationViewController as? SRVideoRouteDetailsViewController {
//                routeVideoDetailsVC.route = selectedRoute;
//                routeVideoDetailsVC.selectedVideoId = selectedVideoMarkId;
//            }
//        }
//    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == kShowVideoSegueIdentifier_1 {
            if let showVideoVC = segue.destinationViewController as? SRShowVideoViewController {
                showVideoVC.fileURL = videoURL!;
            }
        }
    }
}
