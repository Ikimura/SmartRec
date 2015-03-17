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
        
        self.title = "Route";
    }
    
    //MARK: - public
    
    func loadRouteIfNeeded(mode: SRRoutePathMode) {
        
        var myCoordinateMarker: GMSMarker = GMSMarker(position: myCoordinate!);
        myCoordinateMarker.map = mapView;
        
        var targetCoordinateMarker: GMSMarker = GMSMarker(position: targetCoordinate!);
        targetCoordinateMarker.map = mapView;
        
//        var flag: Bool = (routePaths.count - 1) < mode.value;
        
        if (routePaths.count == 0) {
            
            self.loadRoute(mode);
            
        } else {
            
//            self.showRouteData(drivingPathMetrics!["distance"]!, duration: drivingPathMetrics!["duration"]!);
//            self.makeRoute(routePaths[mode.value]!, id: pathMetrics[mode.value]!["id"]!, strokeWidth: 3, colored: UIColor.redColor());
        }
    }
    
    //MARK: - private
    
    private func loadRoute(mode: SRRoutePathMode) {
        
        var complitionBlock = { [weak self] (path: GMSPath, metrics: Dictionary<String, String>) -> Void in
            
            if let strongSelf = self {
                
//                strongSelf.routePaths.appen// showRouteData(metrics["distance"]!, duration: metrics["duration"]!);
//                strongSelf.makeRoute(path, id: metrics["id"]!, strokeWidth: 3, colored: UIColor.redColor());
            }
        };
        
        googleServicesProvider.googleDirectionFrom(myCoordinate!, to: targetCoordinate!, mode: mode.title.rawValue, complitionBlock: complitionBlock) { (error) -> Void in
            
            println(error);
        }
        
    }
    
    private func showRouteData(distance: String, duration: String) {
        
        metricsLabel.text = "Distance: \(distance). Duration: \(duration).";
    }
    
    
    //MARK: - Handler
    
    @IBAction func doneDidTap(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didChangeRouteType(sender: AnyObject) {
        
        var button = sender as? UIBarButtonItem;
        
        if (button?.title == "Walking") {
            
            button?.title = "Driving";
            pathMode = (title: .Driving, value: 1);
            
        } else {
            
            button?.title = "Walking";
            pathMode = (title: .Walking, value: 0);
        }
        
        self.loadRouteIfNeeded(pathMode)
    }
    
}