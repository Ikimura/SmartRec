//
//  SRRouteMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/13/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import CoreData

class SRRouteMapViewController: SRCommonViewController, GMSMapViewDelegate {
    @IBOutlet var googleMapView: GMSMapView!
    
    private var myCoordinate: CLLocationCoordinate2D!;
    private var targetCoordinate: CLLocationCoordinate2D!;
    
    private var results: [AnyObject]?;
    //stubs
    private var stubPaths: [CLLocationCoordinate2D]? = [];
    
    private lazy var mapInfoView: SRMarkerInfoView! = {
        if let infoView = UIView.viewFromNibName("SRMarkerInfoView") as? SRMarkerInfoView!  {
            return infoView;
        } else {
            return nil;
        }
    }();
    
    private var videoFileURL: NSURL?;
    
    //MARK: - life cycle
    
    //FIXME: - 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup amp
        self.setUpMapView();
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

        appDelegate.coreDataManager.fetchEntities(kManagedObjectRoute, withCompletion: { [weak self] (result, error) -> Void in
            if var blockSelf = self {
                
                blockSelf.results = result;
                
                for (_, route) in enumerate(blockSelf.results!) {
                    if let routeItem = route as? SRRoute {
                        println(routeItem.id);
                        
                        var marks = routeItem.videoMarks.allObjects;
                        for (_, routeMark) in enumerate(marks) {
                            if let mark = routeMark as? SRVideoMark {
                                println(mark.latitude.doubleValue);
                                println(mark.longitude.doubleValue);
                                blockSelf.stubPaths!.append(CLLocationCoordinate2D(latitude: mark.latitude.doubleValue, longitude: mark.longitude.doubleValue));
                                
                                //show annotations
                                var dic: [String: AnyObject!] = [
                                    "id": mark.id,
                                    "date": mark.videoData?.date.description,
                                    "fileName": mark.videoData?.fileName,
                                    "lat": mark.latitude.doubleValue,
                                    "lng": mark.longitude.doubleValue,
                                    "photo": mark.thumnailImage];
                                //
                                var place: SRVideoPlace = SRVideoPlace(dictionary: dic);
                                blockSelf.showMarker(place);
                            }
                        }
                    }
                }
                blockSelf.makePolylineFor(blockSelf.stubPaths!);
            }
        });        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
    }
    
    //MARK: - private interface
    
    private func setUpMapView() {
        if let location = SRLocationManager.sharedInstance.currentLocation() as CLLocation! {
            googleMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            myCoordinate = location.coordinate;
        }
        
        googleMapView.delegate = self;
        googleMapView.mapType = kGMSTypeNormal;
        googleMapView.myLocationEnabled = true
    }
    
    private func makePolylineFor(paths: [CLLocationCoordinate2D]){
        var gmsPaths: GMSMutablePath = GMSMutablePath();
        
        for (_, path) in enumerate(paths) {
            gmsPaths.addCoordinate(path);
        }
        
        var polyline: GMSPolyline = GMSPolyline(path: gmsPaths);
        polyline.strokeColor = UIColor.blueColor();
        polyline.strokeWidth = 5;
        polyline.map = googleMapView;
    }
    
    private func showMarker(place: SRVideoPlace) {
        var marker: SRRouteMarker = SRRouteMarker(routePoint: place);
        marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = googleMapView;
    }
    
    //MARK: - GMSMapViewDelegate

    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        
    }
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        if let routeMarker = marker as? SRRouteMarker {
            videoFileURL = NSURL.URL(directoryName: kFileDirectory, fileName: "\(routeMarker.routePoint.fileName).mov");
            println(videoFileURL);
            self.performSegueWithIdentifier(kShowVideoDetailSegueIdentifier, sender: self);
        }
    }
    
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView! {
        
        if let routeMarker = marker as? SRRouteMarker {
            let anchor = marker.position;
            
            mapInfoView.titleLabel.text = routeMarker.routePoint.fileName;
            mapInfoView.subtitleLabel.text = routeMarker.routePoint.date;
            
            if let photo = routeMarker.routePoint.photo {
                mapInfoView.imageView.image = photo;
            }
        }
        
        return mapInfoView;
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
        if segue.identifier == kShowVideoDetailSegueIdentifier {
            if let showVideoVC = segue.destinationViewController as? SRShowVideoViewController {
                showVideoVC.fileURL = videoFileURL!;
            }
        }
    }

}
