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
//                                    if let blockMark = mark {
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
//                                    }
                                });
                            }
                        };
                    }
                }
            }
        });
    }
    
    //MARK: - GMSMapViewDelegate

    override func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        if let tempMarker = marker as? SRRouteMarker {
            var temp = routes?.filter({ (r: SRRoute) -> Bool in
                return r.id == tempMarker.routeID;
            });
            selectedRoute = temp?.first;
            selectedVideoMarkId = tempMarker.videoPoint.videoIdentifier;
            
            self.performSegueWithIdentifier(kDisplayVideoRouteDetailsSegueIdentifier_2, sender: self);
        }
    }

    //FIXME: fix
//    private func makeRoute() {
//        var myCoordinateMarker: GMSMarker = GMSMarker(position: myCoordinate!);
//        myCoordinateMarker.map = googleMapView;
//        
//        let orLat = String(format: "%.4f", myCoordinate.latitude);
//        let orLong = String(format: "%.4f", myCoordinate.longitude);
//
//        let dLat = String(format: "%.4f", targetCoordinate.latitude);
//        let drLong = String(format: "%.4f", targetCoordinate.longitude);
//
//        var getString: String = "origin=\(orLat),\(orLong)&destination=\(dLat),\(drLong)&sensor=true&units=imperial";
//        
//        getString = getString.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!;
//        
//        var stringURL: String = "\(kGoogleMapsAPIURL)?\(getString)";
//        
//        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: stringURL)!);
//        request.HTTPMethod = "GET";
//        
//        var operation: AFHTTPRequestOperation = AFHTTPRequestOperationManager().HTTPRequestOperationWithRequest(request, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
//            
//            var routes: AnyObject! = responseObject["routes"];
//            var c = routes.count;
//            if let temp1 = routes as? [AnyObject] {
//                
//                var tempRoute: AnyObject! = temp1[0];
//                var route: AnyObject! = tempRoute.objectForKey("overview_polyline")!;
//                var overview_route: String! = route.objectForKey("points") as? String;
//                let path: GMSPath = GMSPath(fromEncodedPath: overview_route);
//
//                var polyline: GMSPolyline = GMSPolyline(path: path);
//                polyline.strokeWidth = 3;
//                polyline.strokeColor = UIColor.blueColor();
//                polyline.map = self.googleMapView;
//            
//                println("asd");
//            }
//
//            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
//                println("error");
//        });
//        
//        operation.start();
//    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
        if segue.identifier == kDisplayVideoRouteDetailsSegueIdentifier_2 {
            if let routeVideoDetailsVC = segue.destinationViewController as? SRVideoRouteDetailsViewController {
                routeVideoDetailsVC.route = selectedRoute;
                routeVideoDetailsVC.selectedVideoId = selectedVideoMarkId;
            }
        }
    }

}
