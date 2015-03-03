//
//  SRPlacesSearchViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/28/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import UIKit

class SRPlacesSearchViewController: UISearchController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
    
    private var places: [SRGooglePlace] = [];
    private var searchTimer: NSTimer?;
    private var tableView: UITableView?;
    private lazy var googleServicesProvider: SRGoogleServicesDataProvider = {
        var tempProvider = SRGoogleServicesDataProvider();
        return tempProvider;
    }();
    
    private let searchTimeInterval: NSTimeInterval = 0.3;
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nil, bundle: nil);
        
    }
    
    override init() {
        var searchResultsTableViewController: UITableViewController = UITableViewController();
        self.tableView = searchResultsTableViewController.tableView;
        
        super.init(searchResultsController: searchResultsTableViewController);
        self.tableView = searchResultsTableViewController.tableView;
        self.searchBar.tintColor = UIColor(red: 26.0/255.0, green: 70.0/255.0, blue: 98.0/255.0, alpha: 1.0);
        
        self.searchResultsUpdater = self;
        
        searchResultsTableViewController.tableView.dataSource = self;
        searchResultsTableViewController.tableView.delegate = self;
    }
    
    required init(coder:NSCoder) {
        super.init(coder:coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView?.registerNib(UINib(nibName: "SRPlacesListTableViewCell", bundle: nil), forCellReuseIdentifier: kPlacesListCellIdentifier);

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func searchPlacesByText(searchText: String) {
        
        var coordinate = SRLocationManager.sharedInstance.currentLocation()?.coordinate;
        
        googleServicesProvider.placeTextSearch(self.searchBar.text, lat: coordinate?.latitude, lng: coordinate?.longitude, radius: 1000, types: nil, complitionBlock: { [weak self] (data) -> Void in
            
            if var strongSelf = self {
                
                strongSelf.places = data;
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    strongSelf.tableView!.reloadData();
                })
            }
            
        }) { [weak self] (error) -> Void in
            
            if var strongSelf = self {
                
                if let userInfo = error.userInfo as NSDictionary! {
                    
                    strongSelf.showAlertWith("Error Occuried", message: userInfo["NSLocalizedDescription"] as String);
                }
            }
        }
    }
    
    private func showAlertWith(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Search Timer
    
    private func startSearchTimer() {
        
        if(searchTimer == nil) {
            
            searchTimer = NSTimer.scheduledTimerWithTimeInterval(searchTimeInterval, target: self, selector: "searchTimerFire:", userInfo: nil, repeats: false);
        } else {
            searchTimer?.fireDate = NSDate().dateByAddingTimeInterval(searchTimeInterval);
        }
    }

    func searchTimerFire(timer: NSTimer) {
        
        searchTimer?.invalidate();
        searchTimer = nil;
        
        if (self.searchBar.text.utf16Count > 1) {
            
            self.searchPlacesByText(searchBar.text);
        }
    }
    
    //MARK: - UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        self.startSearchTimer();
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return places.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Cell
        var cell: SRPlacesListTableViewCell? = tableView.dequeueReusableCellWithIdentifier(kPlacesListCellIdentifier) as? SRPlacesListTableViewCell;
        
        cell?.imageView?.cancelImageRequestOperation();
        
        var place: SRGooglePlace = places[indexPath.row];
        cell!.nameLabel.text = "\(place.name!)";
        
        if (place.formattedPhoneNumber != nil) {
            
            cell!.phoneLabel.text = place.formattedPhoneNumber;
            
        } else {
            cell!.phoneLabel.text = nil;
        }
        
        cell!.addressLabel.text = place.formatedAddres;
        
        cell!.cityStateZipLabel.text = nil;
        if (place.distance != nil) {
            
            cell!.distanceLabel.text = "\(place.distance), m";
            
        } else {
            
            cell!.distanceLabel.text = nil;
            cell!.locationImage.image = nil;
        }
        
        cell!.iconImage.setImageWithURL(place.iconURL, placeholderImage: UIImage(named: "image_placeholder"));
        
        return cell!;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //FIXME: - add Logic
        active = false;
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
