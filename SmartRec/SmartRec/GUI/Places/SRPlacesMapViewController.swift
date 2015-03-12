//
//  SRPlacesMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/25/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

// State restoration values.
struct SearchControllerRestorableState {
    var wasActive = false
    var wasFirstResponder = false
}

struct RestorationKeys {
    static let viewControllerTitle = "ViewControllerTitleKey"
    static let searchControllerIsActive = "SearchControllerIsActiveKey"
    static let searchBarText = "SearchBarTextKey"
    static let searchBarIsFirstResponder = "SearchBarIsFirstResponderKey"
}

enum SRControllerMode: String {
    
    case Map = "Map";
    case List = "List";
}

class SRPlacesMapViewController: SRBaseMapViewController, SRPlacesListViewControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    var placesTypes: [(name: String, value: String)]?;
    
    private var googlePlaces: [SRGooglePlace] = [];
    private var rightBarButtonItem: UIBarButtonItem?;
    private lazy var googleServicesProvider: SRGoogleServicesDataProvider = {
        var tempProvider = SRGoogleServicesDataProvider();
        return tempProvider;
    }();
    private var selectedData: Any?;

    //MARK:- searController
    private var restoredState = SearchControllerRestorableState();
    // Search controller to help us with filtering.
    private var searchController: UISearchController!
    // Secondary search results table view.
    private var resultsTableController: SRPlacesListViewController!
    
    required override init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.setUpSearchController();
        self.loadPlacesWithTypes(placesTypes, textSearch: nil, coordinates: self.initialLocation(), radius: 1000, isQeurySearch: false);
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController.active = restoredState.wasActive
            restoredState.wasActive = false
            
            if restoredState.wasFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
    }
    
    private func setUpSearchController() {
        
        resultsTableController = SRPlacesListViewController()
        resultsTableController.delegate = self;
        
        searchController = UISearchController(searchResultsController: resultsTableController);
        searchController.searchResultsUpdater = self;
        searchController.searchBar.sizeToFit();
        self.navigationItem.titleView = searchController!.searchBar;
        
        searchController.delegate = self;
        searchController.dimsBackgroundDuringPresentation = false; // default is YES
        searchController.searchBar.delegate = self;    // so we can monitor text changes + others
        searchController.hidesNavigationBarDuringPresentation = false;
        
        // Search is now just presenting a view controller. As such, normal view controller
        // presentation semantics apply. Namely that presentation will walk up the view controller
        // hierarchy until it finds the root view controller or one that defines a presentation context.
        definesPresentationContext = true;
    }
    
     override func setUpNavigationBar() {
        
        if (self.navigationController != nil) {
            
            var searchButton = UIBarButtonItem(title: "List", style: .Plain, target: self, action: "didSelectRightButton:");
            self.navigationItem.rightBarButtonItem = searchButton;
            
            searchButton.possibleTitles = NSSet(array: ["Map"]);
            rightBarButtonItem = searchButton;
        }
    }
    
    //MARK: - Handler
    
    private func toggleController(mode: SRControllerMode) {
        
        let resultsController = searchController.searchResultsController as SRPlacesListViewController;
        
        switch (mode) {
        case .Map:
            rightBarButtonItem?.title = "List";
            
            if (resultsController.placesList.count != 0) {
                
                self.googlePlaces = resultsController.placesList;
                self.refreshData();
            }

            searchController.active = false;
            
        case .List:
            
            rightBarButtonItem?.title = "Map";
            
            searchController.active = true;
            
            resultsController.placesList = self.googlePlaces;
            
            resultsController.view.hidden = false;
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                resultsController.tableView.reloadData();
            });

        default:
            println("No such Mode!!!");
        }
        
    }
    
    func didSelectRightButton(sender: UIBarButtonItem) {
        
        if (searchController.active) {
            
            self.toggleController(SRControllerMode(rawValue: "Map")!);
            
        } else {

            self.toggleController(SRControllerMode(rawValue: "List")!);
        }
    }
    
    //MARK: - SRPlacesListViewControllerDelegate
    
    func placesListController(controller: SRPlacesListViewController, didSelectPlace place: SRGooglePlace) {
        
        selectedData = place;
        performSegueWithIdentifier(kShowPlaceDetailsSegueIdentifier, sender: controller);
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: UISearchControllerDelegate
    
    func didPresentSearchController(searchController: UISearchController) {
        //NSLog(__FUNCTION__)
        rightBarButtonItem?.title = "Map";
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        //NSLog(__FUNCTION__)
        rightBarButtonItem?.title = "List";
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        var coordinate = appDelegate.currentLocation().coordinate;

        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        
        if (strippedString.utf16Count != 0) {
            
            self.loadPlacesWithTypes(nil, textSearch: strippedString, coordinates: coordinate, radius: 1000, isQeurySearch: true);
        }
    }
    
    // MARK: UIStateRestoration
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        
        // Encode the view state so it can be restored later.
        
        // Encode the title.
        coder.encodeObject(navigationItem.title!, forKey:RestorationKeys.viewControllerTitle)
        
        // Encode the search controller's active state.
        coder.encodeBool(searchController.active, forKey:RestorationKeys.searchControllerIsActive)
        
        // Encode the first responser status.
        coder.encodeBool(searchController.searchBar.isFirstResponder(), forKey:RestorationKeys.searchBarIsFirstResponder)
        
        // Encode the search bar text.
        coder.encodeObject(searchController.searchBar.text, forKey:RestorationKeys.searchBarText)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        
        // Restore the title.
        if let decodedTitle = coder.decodeObjectForKey(RestorationKeys.viewControllerTitle) as? String {
            title = decodedTitle
        }
        else {
            fatalError("A title did not exist. In your app, handle this gracefully.")
        }
        
        // Restore the active state:
        // We can't make the searchController active here since it's not part of the view
        // hierarchy yet, instead we do it in viewWillAppear.
        //
        restoredState.wasActive = coder.decodeBoolForKey(RestorationKeys.searchControllerIsActive)
        
        // Restore the first responder status:
        // Like above, we can't make the searchController first responder here since it's not part of the view
        // hierarchy yet, instead we do it in viewWillAppear.
        //
        restoredState.wasFirstResponder = coder.decodeBoolForKey(RestorationKeys.searchBarIsFirstResponder)
        
        // Restore the text in the search field.
        searchController.searchBar.text = coder.decodeObjectForKey(RestorationKeys.searchBarText) as String
    }
    
    //MARK: - data update
    
    private func refreshData() {
        
        if let baseView = self.view as? SRBaseMapView {
            
            baseView.reloadMarkersList();
        }
    }
    
    private func loadPlacesWithTypes(types: [(name: String, value: String)]?, textSearch: String?, coordinates: CLLocationCoordinate2D?, radius: Int?, isQeurySearch: Bool) {
        
        var complitionBlock = { [weak self](data: [SRGooglePlace]!) -> () in
            
            if var strongSelf = self {
                
                if (isQeurySearch) {
                    
                    let resultsController = strongSelf.searchController.searchResultsController as SRPlacesListViewController;
                    resultsController.placesList = data;
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        resultsController.tableView.reloadData();
                    });
                    
                } else {
                    
                    strongSelf.googlePlaces = data;
                    strongSelf.refreshData();
                }
                
                if (strongSelf.googlePlaces.count == 0 && !isQeurySearch) {
                    //TODO: change to localized strings
                    strongSelf.showAlertWith("Attention", message: "No Data Available");
                }
            }
        };
        
        var errorBlock = { [weak self] (error: NSError) -> Void in
            
            if var strongSelf = self {
                
                if let userInfo = error.userInfo as NSDictionary! {
                    
                    strongSelf.showAlertWith("Error Occuried", message: userInfo["NSLocalizedDescription"] as String);
                }
            }
        }
        
        var stringTypes: [String] = [];
        if (types != nil) {
            for var i = 0; i < types!.count; i++ {
                stringTypes.append(types![i].1);
            }
        }
        
        if (isQeurySearch) {
            
            googleServicesProvider.placeTextSearch(textSearch!, lat: coordinates?.latitude, lng: coordinates?.longitude, radius: radius, types: stringTypes, complitionBlock: complitionBlock, errorComplitionBlock: errorBlock);
            
        } else {
         
            googleServicesProvider.nearbySearchPlaces(coordinates!.latitude, lng: coordinates!.longitude, radius: radius!, types: stringTypes, keyword: nil, name: nil, complitionBlock: complitionBlock, errorComplitionBlock: errorBlock);
        }
        
    }
    
    //MARK: - SRBaseMapViewDataSource
    
    override func initialLocation() -> CLLocationCoordinate2D {
        
        return appDelegate.currentLocation().coordinate;
    }
    
    override func numberOfMarkers() -> Int {
        
        return self.googlePlaces.count;
    }
    
    override func titleForMarkerAtIndex(index: Int) -> String? {
        
        var title = "";
        
        if let place = self.googlePlaces[index] as SRGooglePlace! {
            
            title = place.name!;
        }
        
        return title;
    }
    
    override func locationForMarkerAtIndex(index: Int) -> CLLocationCoordinate2D? {
        
        let place = self.googlePlaces[index] as SRGooglePlace!;
        var coordinate = CLLocationCoordinate2DMake(place.lat, place.lng);
        
        return coordinate;
    }
    
    override func iconForMarkerAtIndex(index: Int) -> UIImage? {
        return UIImage(named: "citiPin");
    }
    
    //MARK: - SRBaseMapViewDelegate
    
    override func calloutAccessoryControlTappedByIdentifier(identifier: AnyObject) {
        
        if let number = identifier as? NSNumber {
            
            selectedData = number.integerValue;
            performSegueWithIdentifier(kShowPlaceDetailsSegueIdentifier, sender: self);
        }
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        
        var selectedPlace: SRGooglePlace?;
        
        switch (sender) {
            
        case is SRPlacesMapViewController:
            selectedPlace = googlePlaces[selectedData as Int];
            
        case is SRPlacesListViewController:
            selectedPlace = selectedData as? SRGooglePlace;
            
        default:
            fatalError("Unknown Sender");
        }
        
        if (segue.identifier == kShowPlaceDetailsSegueIdentifier) {
            
            if let navigationVC = segue.destinationViewController as? UINavigationController {
                
                if let placeDetailsVC = navigationVC.viewControllers[0] as? SRPlacesDetailsTableViewController {
                    placeDetailsVC.place = selectedPlace;
                }
            }
        }
    }
}
