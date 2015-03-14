////
////  SRCoommonMapViewController.swift
////  SmartRec
////
////  Created by Artsiom Karseka on 12/24/14.
////  Copyright (c) 2014 con.epam.evnt. All rights reserved.
////
//
//import UIKit
//import CoreData
//TODO: Delete
//class SRCommonMapViewController: SRCommonViewController, GMSMapViewDelegate {
//    @IBOutlet var googleMapView: GMSMapView!
//    
//    private lazy var mapInfoView: SRMarkerInfoView! = {
//        if let infoView = UIView.viewFromNibName("SRMarkerInfoView") as? SRMarkerInfoView!  {
//            return infoView;
//        } else {
//            return nil;
//        }
//    }();
//    
//    //MARK: - nav bar behavior
//    
//    func toggle(sender: AnyObject) {
//        navigationController?.setNavigationBarHidden(navigationController?.navigationBarHidden == false, animated: true) //or animated: false
//    }
//    
//    override func prefersStatusBarHidden() -> Bool {
//        return navigationController?.navigationBarHidden == true;
//    }
//    
//    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
//        return UIStatusBarAnimation.Fade;
//    }
//    
//    //MARK: - internal interface
//    
//    func setUpMapViewWith(location: CLLocation?) {
//        if (location != nil) {
//            googleMapView.camera = GMSCameraPosition(target: location!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
//        }
//        
//        googleMapView.delegate = self;
//        googleMapView.mapType = kGMSTypeNormal;
//        googleMapView.myLocationEnabled = true
//    }
//    
//    func makePolylineForRoute(route: AnyObject){
//        var gmsPaths: GMSMutablePath = GMSMutablePath();
//        
//        if var tempRoute = route as? SRRoute {
//            tempRoute.routePoints.enumerateObjectsUsingBlock {[weak self] (element, index, stop) -> Void in
//                if var blockSelf = self {
//                    if let routePoint = element as? SRRoutePoint {
//                        gmsPaths.addCoordinate(CLLocationCoordinate2D(latitude: routePoint.latitude.doubleValue, longitude: routePoint.longitude.doubleValue));
//                        //display markers for points
//                        //TODO: forme SRPointMapMarker
//                        blockSelf.showGoogleMapMarker(SRPointMapMarker(routeID: tempRoute.id));
//                    }
//                }
//            };
//            var polyline: SRMapPolyline = SRMapPolyline(path: gmsPaths);
//            polyline.tappable = true;
//            polyline.routeID = tempRoute.id;
//            polyline.strokeColor = UIColor.blueColor();
//            polyline.strokeWidth = 5;
//            polyline.map = googleMapView;
//        }
//    }
//    
//    func markVideoMarkersForRoute(route: AnyObject) {
//        if var tempRoute = route as? SRRoute {
//            tempRoute.videoMarks.enumerateObjectsUsingBlock { [weak self] (element, index, stop) -> Void in
//                if let mark = element as? SRRouteVideoPoint {
//                    dispatch_async(dispatch_get_main_queue(), {() -> Void in
//                        //show annotations
//                        var dic: [String: AnyObject!] = [
//                            "id": mark.id,
//                            "date": mark.videoData!.date.description,
//                            "fileName": mark.videoData!.fileName,
//                            "lat": mark.latitude.doubleValue,
//                            "lng": mark.longitude.doubleValue,
//                            "photo": mark.thumnailImage];
//                        //
//                        var place: SRVideoPlace = SRVideoPlace(dictionary: dic);
//                        
//                        var routeMarker = SRVideoMapMarker(videoPoint: place, routeID: route.id);
//                        
//                        if var blockSelf = self {
//                            blockSelf.showGoogleMapMarker(routeMarker);
//                        }
//                    });
//                }
//            };
//        }
//    }
//    
//    func showGoogleMapMarker(marker: SRBaseMapMarker) {
//        marker.appearAnimation = kGMSMarkerAnimationPop;
//        marker.map = googleMapView;
//    }
//    
//    
//    //MARK: - private interface
//    
//    
//    
//    //MARK: - GMSMapViewDelegate
//    
//    func mapView(mapView: GMSMapView, didTapOverlay overlay:GMSOverlay) {
//
//    }
//    
//    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
//        
//    }
//    
//    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
//        return false;
//    }
//    
//    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
//        self.toggle(mapView);
//    }
//    
//    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView! {
//        
//        if let routeMarker = marker as? SRVideoMapMarker {
//            let anchor = marker.position;
//            
//            mapInfoView.titleLabel.text = routeMarker.videoPoint.fileName;
//            mapInfoView.subtitleLabel.text = routeMarker.videoPoint.date;
//            
//            if let photo = routeMarker.videoPoint.photo {
//                mapInfoView.pictureImageView.image = photo;
//            }
//        }
//        
//        return mapInfoView;
//    }
//    
//}
