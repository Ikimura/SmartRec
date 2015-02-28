//
//  SRPlacesSearchViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/28/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import UIKit

class SRPlacesSearchViewController: UISearchController, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate {
    
    private var places: [SRGooglePlace]?;
    private var searchTimer: NSTimer?;
    private var tableView: UITableView?;
    
    private let searchTimeInterval: NSTimeInterval = 0.3;
    
    override init() {
        
        var searchResultsTableViewController: UITableViewController = UITableViewController();
        tableView = searchResultsTableViewController.tableView;
        
        super.init(searchResultsController: searchResultsTableViewController);
        
        self.searchBar.tintColor = UIColor(red: 26.0/255.0, green: 70.0/255.0, blue: 98.0/255.0, alpha: 1.0);
        
        self.searchResultsUpdater = self;
        
        searchResultsTableViewController.tableView.dataSource = self;
        searchResultsTableViewController.tableView.delegate = self;
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func searchPlacesByText(searchText: String) {
     //TODO: create google service
        /*
        [[BCDataProvider sharedProvider] placeSearchWithQuery:self.searchBar.text completion:^(NSArray *listOfPlace) {
        self.listOfPlace = listOfPlace;
        [self.tableView reloadData];
        } error:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Error!" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
        }];
        */
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
        
        return places!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Cell
        var cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("simpleCell") as? UITableViewCell;
        
        if (cell == nil) {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "simpleCell");
        }
        
        var place: SRGooglePlace = places![indexPath.row];
        
        cell?.textLabel?.text = place.name;
        cell?.detailTextLabel?.text = place.vicinity;
        
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
