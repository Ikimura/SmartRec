//
//  SRPlacesMapViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/25/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

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
    case List =  "List";
}

class SRPlacesMapViewController: SRBaseMapViewController, SRPlacesListViewControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    var placesTypes: [(name: String, value: String)]?;
    
    private var googlePlaces: [SRCoreDataPlace] = [];
    private var rightBarButtonItem: UIBarButtonItem?;
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
            
            var searchButton = UIBarButtonItem(title: NSLocalizedString("list_naviagtion_button_title", comment:""), style: .Plain, target: self, action: "didSelectRightButton:");
            self.navigationItem.rightBarButtonItem = searchButton;
            
            searchButton.possibleTitles = NSSet(array: [NSLocalizedString("map_naviagtion_button_title", comment:"")]);
            rightBarButtonItem = searchButton;
        }
    }
    
    //MARK: - Handler
    
    private func toggleController(mode: SRControllerMode) {
        
        let resultsController = searchController.searchResultsController as SRPlacesListViewController;
        
        switch (mode) {
        case .Map:
            rightBarButtonItem?.title = NSLocalizedString("list_naviagtion_button_title", comment:"");
            
            if (resultsController.placesList.count != 0) {
                
                self.googlePlaces = resultsController.placesList;
                self.refreshData();
            }

            searchController.active = false;
            
        case .List:
            
            rightBarButtonItem?.title = NSLocalizedString("map_naviagtion_button_title", comment:"");
            
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
    
    func placesListController(controller: SRPlacesListViewController, didSelectPlace place: SRCoreDataPlace) {
        
        selectedData = place;
        performSegueWithIdentifier(kShowPlaceDetailsSegueIdentifier, sender: controller);
    }
    
    // MARK: UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - UISearchControllerDelegate
    
    func didPresentSearchController(searchController: UISearchController) {
        //NSLog(__FUNCTION__)
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        
        UIView.animateWithDuration(0.33, animations: {[weak self] () -> Void in
            
            if let strongSelf  = self {
                strongSelf.navigationItem.rightBarButtonItem = nil;
            }
        });
    }
    
    func willDismissSearchController(searchController: UISearchController) {
        //NSLog(__FUNCTION__)
        UIView.animateWithDuration(0.33, animations: {[weak self] () -> Void in

            if let strongSelf  = self {
                
                strongSelf.navigationItem.rightBarButtonItem = strongSelf.rightBarButtonItem;
            }
        });
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        var coordinate = appDelegate.currentLocation().coordinate;

        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchController.searchBar.text.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        
        if (strippedString.utf16Count >= 3) {
            
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
        
        var tempComplitionBlock = { [weak self]( placeIds:[String]?, error: NSError?) -> Void in
            
            if var strongSelf = self {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    strongSelf.hideBusyView();
                });
                
                if (placeIds != nil && placeIds?.count != 0) {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        var context = SRCoreDataContextProvider.mainManagedObjectContext();
                        var fetchRequest = NSFetchRequest(entityName: "SRCoreDataPlace");

                        //FIXME: - исправить костыль
                        var predArray : Array<NSPredicate> = []
                        for id in placeIds! {
                            
                            predArray.append(NSPredicate(format: "placeId LIKE %@", id)!);
                        }
                    
                        fetchRequest.predicate = NSCompoundPredicate(type: NSCompoundPredicateType.OrPredicateType, subpredicates: predArray);
                        
                        var cdError: NSError?;
                        var pl = context.executeFetchRequest(fetchRequest, error: &cdError) as? [SRCoreDataPlace];
                        
                        if (cdError == nil) {
                            
                            if (isQeurySearch) {
                                
                                let resultsController = strongSelf.searchController.searchResultsController as SRPlacesListViewController;
                                
                                resultsController.placesList = pl!;
                                resultsController.tableView.reloadData();
                                
                            } else {
                                
                                strongSelf.googlePlaces = pl!;
                                strongSelf.refreshData();
                            }
                            
                        } else {
                            
                            if let userInfo = cdError!.userInfo as NSDictionary! {
                                
                                strongSelf.showAlertWith(NSLocalizedString("alert_error_title", comment:""), message: userInfo["NSLocalizedDescription"] as String);
                            }
                        }
                    });
                    
                } else {
                    
                    if (strongSelf.googlePlaces.count == 0 && !isQeurySearch) {
                        
                        strongSelf.showAlertWith(NSLocalizedString("alert_attention_title", comment:""), message: NSLocalizedString("alert_attention_body", comment:""));
                        
                    } else if (error != nil) {
                        
                        if let userInfo = error!.userInfo as NSDictionary! {
                            
                            strongSelf.showAlertWith(NSLocalizedString("alert_error_title", comment:""), message: userInfo["NSLocalizedDescription"] as String);
                        }
                    }
                }
            }
        }
        
        var stringTypes: [String] = [];
        if (types != nil) {
            for var i = 0; i < types!.count; i++ {
                stringTypes.append(types![i].1);
            }
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
        if (appDelegate.isOfflineMode) {
            
            self.showBusyView();

            SRPlacesController.sharedInstance.cashedPlacesWith(stringTypes, textSearch: textSearch, andLocationCordinate: coordinates!, inRadius: 1000.0, complitionBlock: tempComplitionBlock);
            
        } else {
            
            if (isQeurySearch) {
                
                self.showBusyView();
                
                SRPlacesController.sharedInstance.textSearchPlace(textSearch!, coordinate: coordinates, radius: radius, types: stringTypes, complitionBlock: tempComplitionBlock);
                
            } else {
                
                self.showBusyView();
                
                SRPlacesController.sharedInstance.nearbyPlaces(coordinates!, radius: radius!, types: stringTypes, keyword: nil, name: nil, complitionBlock: tempComplitionBlock);
            }
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
        
        if let place = self.googlePlaces[index] as SRCoreDataPlace! {
            
            title = place.name;
        }
        
        return title;
    }
    
    override func locationForMarkerAtIndex(index: Int) -> CLLocationCoordinate2D? {
        
        let place = self.googlePlaces[index] as SRCoreDataPlace!;
        var coordinate = CLLocationCoordinate2DMake(place.lat, place.lng);
        return coordinate;
    }
    
    override func iconForMarkerAtIndex(index: Int) -> UIImage? {
        return UIImage(named: "pin");
    }
    
    //MARK: - SRBaseMapViewDelegate
    
    override func calloutAccessoryControlTappedByIdentifier(identifier: AnyObject) {
        
        if let number = identifier as? NSNumber {
            
            selectedData = number.integerValue;
            performSegueWithIdentifier(kShowPlaceDetailsSegueIdentifier, sender: self);
        }
    }
    
    override func didChangeCameraPosition(position: GMSCameraPosition, byGesture: Bool) {
        
        println("GEture")
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        
        var selectedPlace: SRCoreDataPlace?;
        
        switch (sender) {
            
        case is SRPlacesMapViewController:
            selectedPlace = googlePlaces[selectedData as Int];
            
        case is SRPlacesListViewController:
            
            selectedPlace = selectedData as? SRCoreDataPlace;
            
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
