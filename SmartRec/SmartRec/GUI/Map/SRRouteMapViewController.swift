//
//  SRRouteMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/13/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit

class SRRouteMapViewController: SRCommonViewController, SRLocationManagerDelegate {
    @IBOutlet var googleMapView: GMSMapView!
    
    var myCoordinate: CLLocationCoordinate2D!;
    var targetCoordinate: CLLocationCoordinate2D!;

    //MARK: - life cycle
    
    //FIXME: - 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SRLocationManager.sharedInstance.delegate = self;
        
        SRLocationManager.sharedInstance.startMonitoringLocation();
        
        googleMapView.mapType = kGMSTypeNormal;
        googleMapView.myLocationEnabled = true
        
        targetCoordinate = CLLocationCoordinate2D(latitude: 53.902253, longitude: 27.5618629);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        
    }
    
    //MARK: - SRLocationManagerDelegate

    func srlocationManager(manager: SRLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        SRLocationManager.sharedInstance.stopMonitoringLocation();

        if let location = locations.first as? CLLocation {
            googleMapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            myCoordinate = location.coordinate;

            self.makeRoute();

        }
    }

    //MARK: - private interface
    
    //FIXME: fix
    private func makeRoute() {
        var myCoordinateMarker: GMSMarker = GMSMarker(position: myCoordinate!);
        myCoordinateMarker.map = googleMapView;
        
        let orLat = String(format: "%.4f", myCoordinate.latitude);
        let orLong = String(format: "%.4f", myCoordinate.longitude);

        let dLat = String(format: "%.4f", targetCoordinate.latitude);
        let drLong = String(format: "%.4f", targetCoordinate.longitude);

        var getString: String = "origin=\(orLat),\(orLong)&destination=\(dLat),\(drLong)&sensor=true&units=imperial";
        
        getString = getString.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)!;
        
        var stringURL: String = "\(kGoogleMapsAPIURL)?\(getString)";
        
        var request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: stringURL)!);
        request.HTTPMethod = "GET";
        
        var operation: AFHTTPRequestOperation = AFHTTPRequestOperationManager().HTTPRequestOperationWithRequest(request, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            
            var routes: AnyObject! = responseObject["routes"];
            var c = routes.count;
            if let temp1 = routes as? [AnyObject] {
                
                var tempRoute: AnyObject! = temp1[0];
                var route: AnyObject! = tempRoute.objectForKey("overview_polyline")!;
                var overview_route: String! = route.objectForKey("points") as? String;
                let path: GMSPath = GMSPath(fromEncodedPath: overview_route);

                var polyline: GMSPolyline = GMSPolyline(path: path);
                polyline.strokeWidth = 3;
                polyline.strokeColor = UIColor.blueColor();
                polyline.map = self.googleMapView;
            
                println("asd");
            }

            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("error");
        });
        
        operation.start();
    }

}
