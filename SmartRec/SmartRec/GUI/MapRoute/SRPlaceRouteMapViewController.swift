//
//  SRPlaceRouteMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/8/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

enum SRRoutePathType: String {
    
    case Walking = "walking";
    case Driving = "driving";
}

typealias SRRoutePathMode = (title: SRRoutePathType, value: Int);

class SRPlaceRouteMapViewController: SRCommonRouteMapViewController {
    
    var targetCoordinate: CLLocationCoordinate2D?;
    var myCoordinate: CLLocationCoordinate2D?;
    
    private lazy var googleServicesProvider: SRGoogleServicesDataProvider = {
        var tempProvider = SRGoogleServicesDataProvider();
        return tempProvider;
        }();
    
    private var routePaths: [GMSPath] = [];
    private var pathMode: SRRoutePathMode = (title: .Walking, value: 0);
    private var pathMetrics: [Dictionary<String, String>] = [];
    
    @IBOutlet weak var metricsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.setUpMap(targetCoordinate!);
        
        self.loadRouteIfNeeded(pathMode);
    }
    
    
    //MARK: - Override
    
    override func setUpNavigationBar() {
        
        self.title = NSLocalizedString("route_title", comment:"");
    }
    
    //MARK: - public
    
    func loadRouteIfNeeded(mode: SRRoutePathMode) {
        
        if (routePaths.count == 0 || (routePaths.count - 1) < mode.value ) {
            
            self.loadRoute(mode);

        } else {
            
            self.refreshMapView(mode);
        }
    }
    
    //MARK: - private
    
    private func refreshMapView(withMode: SRRoutePathMode) {
        
        mapView.clear();
        
        //Show markers
        var myCoordinateMarker: GMSMarker = GMSMarker(position: myCoordinate!);
        myCoordinateMarker.icon = UIImage(named: "you_here");
        myCoordinateMarker.map = mapView;
        
        var targetCoordinateMarker: GMSMarker = GMSMarker(position: targetCoordinate!);
        targetCoordinateMarker.icon = UIImage(named: "fin_pin");
        targetCoordinateMarker.map = mapView;
        
        //Show route
        self.showRouteData(pathMetrics[withMode.value]["distance"]!, duration:pathMetrics[withMode.value]["duration"]!);
        
        var color = pathMode.value == 0 ? UIColor.redColor() : UIColor.blueColor();
        self.makeRoute(routePaths[withMode.value], id: pathMetrics[withMode.value]["id"]!, strokeWidth: 3, colored: color);
    }
    
    private func loadRoute(mode: SRRoutePathMode) {
        
        var complitionBlock = { [weak self] (path: GMSPath, metrics: Dictionary<String, String>) -> Void in
            
            if let strongSelf = self {
                
                //Save routes
                strongSelf.routePaths.append(path);
                strongSelf.pathMetrics.append(metrics);
                
                //show route
                strongSelf.refreshMapView(mode);
            }
        };
        
        googleServicesProvider.googleDirectionFrom(myCoordinate!, to: targetCoordinate!, mode: mode.title.rawValue, complitionBlock: complitionBlock) { (error) -> Void in
            
            println(error);
        }
        
    }
    
    private func showRouteData(distance: String, duration: String) {
        var distTitle = NSLocalizedString("distance_title", comment:"").capitalizedString;
        var durationTitle = NSLocalizedString("duration_title", comment:"").capitalizedString;
        metricsLabel.text = distTitle + ": \(distance). " + durationTitle + ": \(duration).";
    }
    
    
    //MARK: - Handler
    
    @IBAction func doneDidTap(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didChangeRouteType(sender: AnyObject) {
        
        var button = sender as? UIBarButtonItem;
        
        if (button?.title == NSLocalizedString("route_mode_walking_title", comment:"")) {
            
            button?.title = NSLocalizedString("route_mode_driving_title", comment:"");
            pathMode = (title: .Driving, value: 1);
            
        } else {
            
            button?.title = NSLocalizedString("route_mode_walking_title", comment: "");
            pathMode = (title: .Walking, value: 0);
        }
        
        self.loadRouteIfNeeded(pathMode)
    }
    
}