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
                        
                        blockSelf.markVideoMarkersForRoute(route);
                    }
                }
            }
        });
    }
    
    //MARK: - GMSMapViewDelegate
    
    override func mapView(mapView: GMSMapView, didTapOverlay overlay:GMSOverlay) {
        print("didTapOverlay");
        if let selectedOverlay = overlay as? SRMapPolyline {
            
            routes?.filter({ [weak self] (route: SRRoute) -> Bool in
                    if (route.id == selectedOverlay.routeID) {
                        if var blockSelf = self {
                            blockSelf.selectedRoute = route;
                            blockSelf.performSegueWithIdentifier(kDisplayVideoRouteDetailsSegueIdentifier_2, sender: blockSelf);
                        }

                        return true;
                        
                    } else {
                        return false;
                    }
            });

        }
    }
    
    override func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        //Show video
        if let tempMarker = marker as? SRVideoMapMarker {
            if let url = NSURL.URL(directoryName: kFileDirectory, fileName: "\(tempMarker.videoPoint.fileName)\(kFileExtension)") as NSURL! {
                videoURL = url;
            }
            self.performSegueWithIdentifier(kShowVideoSegueIdentifier_1, sender: self);
        }
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        
        switch (segue.identifier!) {
        case kShowVideoSegueIdentifier_1:
            if let showVideoVC = segue.destinationViewController as? SRShowVideoViewController {
                showVideoVC.fileURL = videoURL!;
            }
        case kDisplayVideoRouteDetailsSegueIdentifier_2:
            if let routeVideoDetailsVC = segue.destinationViewController as? SRVideoRouteDetailsViewController {
                routeVideoDetailsVC.route = selectedRoute;
            }
        default:
            println("Segue \(segue.identifier)");
        }
    }
}
