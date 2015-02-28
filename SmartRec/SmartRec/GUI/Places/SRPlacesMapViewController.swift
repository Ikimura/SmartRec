//
//  SRPlacesMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/25/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
//FIXME: Add search Controller
class SRPlacesMapViewController: SRBaseMapViewController {

    var placesTypes: [(name: String, value: String)]?;
    
    private var googlePlaces: [SRGooglePlace]?;
    private var rightBarButtonItem: UIBarButtonItem?;
    private lazy var googleServicesProvider: SRGoogleServicesDataProvider = {
        var tempProvider = SRGoogleServicesDataProvider();
        return tempProvider;
    }();
    
    private lazy var placesListViewController: SRPlacesListViewController = {
        
        var tempVC = SRPlacesListViewController();
        tempVC.placesList = self.googlePlaces;
        tempVC.types = self.placesTypes;
        
        self.addChildViewController(tempVC);
        
        return tempVC;
    }();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.setUpNavigationBar();
        self.loadPlacesWithTypes(placesTypes!, coordinates: self.initialLocation());
    }
    
    private func setUpNavigationBar() {
        
        if (self.navigationController != nil) {
            
            var searchButton = UIBarButtonItem(title: "List", style: .Plain, target: self, action: "didSelectRightButton:");
            self.navigationItem.rightBarButtonItem = searchButton;
            
            searchButton.possibleTitles = NSSet(array: ["Map"]);
            rightBarButtonItem = searchButton;
        }
    }
    
    func didSelectRightButton(sender: UIBarButtonItem) {
        
        var placesListVC = placesListViewController;
        
        var rect = self.view.bounds;
        rect.origin.y = rect.size.height;
        
        var newFrame: CGRect?;
        var present: Bool = true;
        
        if (placesListVC.view.superview != nil) {
            
            sender.title = "List";
            present = false;
            newFrame = rect;
            
        } else {
            
            sender.title = "Map";
            present = true;
            self.view.addSubview(placesListVC.view);
            placesListVC.view.frame = rect;
            newFrame = self.view.bounds;
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            placesListVC.view.frame = newFrame!;
            
            }) { (finished: Bool) -> Void in
            
                if (finished) {
                    
                    if (!present) {
                        
                        placesListVC.view.removeFromSuperview();
                    }
                }
        }
    }
    
    //MARK: - data update
    
    private func loadPlacesWithTypes(types: [(name: String, value: String)], coordinates: CLLocationCoordinate2D) {
        
        var strinTypes: [String] = [];
        for var i = 0; i < types.count; i++ {
            strinTypes.append(types[i].1);
        }
        
        googleServicesProvider.nearbySearchPlaces(coordinates.latitude, lng: coordinates.longitude, radius: 1000, types: strinTypes, keyword: nil, name: nil, complitionBlock: { [weak self] (data) -> Void in
            
            if var strongSelf = self {
                
                strongSelf.googlePlaces = data;
                
                if let baseView = strongSelf.view as? SRBaseMapView {
                    baseView.reloadMarkersList();
                }
                
                if (strongSelf.googlePlaces?.count == 0) {
                    //TODO: change to localized strings
                    strongSelf.showAlertWith("Attention", message: "No Data Available");
                }
            }
        }) { [weak self] (error) -> Void in
            
            if var strongSelf = self {
                
                if let userInfo = error.userInfo as NSDictionary! {
                    
                    strongSelf.showAlertWith("Error Occuried", message: userInfo["NSLocalizedDescription"] as String);
                }
            }
        }
    }
    
    //MARK: - Utils
    
    private func showAlertWith(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: - SRBaseMapViewDataSource
    
    override func initialLocation() -> CLLocationCoordinate2D {
        
        if let location: CLLocationCoordinate2D = SRLocationManager.sharedInstance.currentLocation()?.coordinate {
            
            return location;
            
        } else {
            //GRODNO
            return CLLocationCoordinate2DMake(53.6884000, 23.8258000);
        }
    }
    
    override func numberOfMarkers() -> Int {
        
        var count = 0;
        
        if self.googlePlaces != nil {
            
            count = self.googlePlaces!.count;
        }
        
        return count;
    }
    
    override func titleForMarkerAtIndex(index: Int) -> String? {
        
        var title = "";
        
        if let place = self.googlePlaces?[index] as SRGooglePlace! {
            
            title = place.name!;
        }
        
        return title;
    }
    
    override func locationForMarkerAtIndex(index: Int) -> CLLocationCoordinate2D? {
        
        let place = self.googlePlaces?[index] as SRGooglePlace!;
        var coordinate = CLLocationCoordinate2DMake(place.lat, place.lng);
        
        return coordinate;
    }
    
    override func iconForMarkerAtIndex(index: Int) -> UIImage? {
        return UIImage(named: "citiPin");
    }
    
    //MARK: - SRBaseMapViewDelegate
    
    override func calloutAccessoryControlTappedByIdentifier(identifier: AnyObject) {
        if let number = identifier as? NSNumber {
            
            var index = number.integerValue;
            //TODO: - show information
            
        }
    }
}
