//
//  SRPlaceRouteMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/8/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRPlaceRouteMapViewController: SRCommonRouteMapViewController {
    
    var targetCoordinate: CLLocationCoordinate2D?;
    var myCoordinate: CLLocationCoordinate2D?;
    
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
        
        var complitionBlock = { [weak self] (path: GMSPath, metrics: Dictionary<String, String>) -> Void in
            
            if let strongSelf = self {
                
                if strongSelf.pathMode == "walking" {
                    
                    strongSelf.walkingPath = path;
                    
                } else {
                    
                    strongSelf.drivingPath = path;
                }
                
                strongSelf.showRouteData(metrics["distance"]!, duration: metrics["duration"]!);
                
                strongSelf.makeRoute(path, id: metrics["id"]!, strokeWidth: 3, colored: UIColor.redColor());
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
    
    //MARK: - private
    
    private func showRouteData(distance: String, duration: String) {
        
        metricsLabel.text = "Distance: \(distance). Duration: \(duration).";
    }
    
    
    //MARK: - Handler

    @IBAction func doneDidTap(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}