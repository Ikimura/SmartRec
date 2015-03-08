//
//  SRPlaceRouteMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/8/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRPlaceRouteMapViewController: SRCommonViewController {
    
    var targetCoordinate: CLLocationCoordinate2D?;
    var myCoordinate: CLLocationCoordinate2D?;
 
    @IBOutlet var mapView: GMSMapView!;

    private lazy var googleServicesProvider: SRGoogleServicesDataProvider = {
        var tempProvider = SRGoogleServicesDataProvider();
        return tempProvider;
    }();
    
    private var walkingPath: GMSPath?;
    private var drivingPath: GMSPath?;
    private var pathMode: String = "walking";
    
    @IBOutlet weak var metricsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.setUpMap(targetCoordinate!);
        
        self.loadRoute(pathMode);
    }
    
    //MARK: - Configure
    
    func setUpMap(targetCoordinate: CLLocationCoordinate2D) {
        
        let camera = GMSCameraPosition.cameraWithLatitude(targetCoordinate.latitude, longitude: targetCoordinate.longitude, zoom: 13)
        self.mapView.camera = camera;
    }
    
    //MARK: - Override
    
    override func setUpNavigationBar() {
        
        self.title = "Route";
    }
    //MARK: - public
    
    func loadRoute(mode: String) {
        
        var myCoordinateMarker: GMSMarker = GMSMarker(position: myCoordinate!);
        myCoordinateMarker.map = mapView;
        
        var targetCoordinateMarker: GMSMarker = GMSMarker(position: targetCoordinate!);
        targetCoordinateMarker.map = mapView;
        
        var complitionBlock = { [weak self] (path: GMSPath, metric: (distance: String, duration: String)) -> Void in
            
            if let strongSelf = self {
                
                if strongSelf.pathMode == "walking" {
                    
                    strongSelf.walkingPath = path;
                    
                } else {
                    
                    strongSelf.drivingPath = path;
                }
                
                strongSelf.showRouteData(metric.0, duration: metric.1);
                
                strongSelf.makeRoute(path, colored: UIColor.redColor());
            }
        };
        
        if (mode == "walking" && walkingPath == nil) {
            
            googleServicesProvider.googleDirectionFrom(myCoordinate!, to: targetCoordinate!, mode: mode, complitionBlock: complitionBlock) { (error) -> Void in
                
                println(error);
            }
            
        } else if ( mode == "driving" && drivingPath == nil) {
            
            googleServicesProvider.googleDirectionFrom(myCoordinate!, to: targetCoordinate!, mode: mode, complitionBlock: complitionBlock) { (error) -> Void in
                
                println(error);
            }
        }
    }
    
    func makeRoute(path: GMSPath, colored color: UIColor) {
        
        var polyline = GMSPolyline(path: path);
        polyline.strokeWidth = 3;
        polyline.strokeColor = color;
        
        polyline.map = mapView;
        
        self.zoomToMarkersWithPath(path);
    }
    
    func zoomToMarkersWithPath(path: GMSPath) {
        
        let coordinateBounds = GMSCoordinateBounds(path: path);
        let mapInsets = UIEdgeInsetsMake(110, 20, 60, 20);
        
        let camera = GMSCameraUpdate.fitBounds(coordinateBounds, withEdgeInsets: mapInsets);
        
        mapView.animateWithCameraUpdate(camera);
    }
    
    //MARK: - private
    
    private func showRouteData(distance: String, duration: String) {
        
        metricsLabel.text = "Distance: \(distance). Duration: \(duration).";
    }
    
    
    //MARK: - Handler

    @IBAction func doneDidTap(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}