//
//  SRPlacesListViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/28/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

protocol SRPlacesListViewControllerDelegate {

    func placesListController(controller: SRPlacesListViewController, didSelectPlace place: SRGooglePlace);
}

class SRPlacesListViewController : SRCommonViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!;    
    var placesList: [SRGooglePlace] = [];
    var types: [(name: String, value: String)]?;
    var delegate: SRPlacesListViewControllerDelegate?;
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.tableView.registerNib(UINib(nibName: "SRPlacesListTableViewCell", bundle: nil), forCellReuseIdentifier: kPlacesListCellIdentifier);
        
        if (self.navigationController != nil) {
            
            var inset: UIEdgeInsets = UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController!.navigationBar.frame), 0, 0, 0);
            tableView.scrollIndicatorInsets = inset;
            tableView.contentInset = inset;
        }
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return placesList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: SRPlacesListTableViewCell? = tableView.dequeueReusableCellWithIdentifier(kPlacesListCellIdentifier) as? SRPlacesListTableViewCell;
        
        cell?.imageView?.cancelImageRequestOperation();
        
        var place: SRGooglePlace = placesList[indexPath.row];
        cell!.nameLabel.text = "\(place.name!)";
        
        if (place.formattedPhoneNumber != nil) {
            
            cell!.phoneLabel.text = place.formattedPhoneNumber;
            
        } else {
            cell!.phoneLabel.text = nil;
        }
        
        if (place.vicinity != nil) {
            
            cell!.addressLabel.text = place.vicinity!.capitalizedString;
            
        } else {
            cell!.addressLabel.text = place.formattedAddress!.capitalizedString;
        }
        
//        cell!.cityStateZipLabel.text = nil;
        
        if (place.distance == nil) {
            
            place.addDistance(CLLocation.distanceBetweenLocation(CLLocationCoordinate2DMake(place.lat, place.lng), secondLocation: appDelegate.currentLocation().coordinate));
        }
        var dist = Double(place.distance!);
        var strDist = dist.format(".3");
        
        cell!.distanceLabel.text = "\(strDist), km";
        
        cell!.iconImage.setImageWithURL(place.iconURL, placeholderImage: UIImage(named: "image_placeholder"));
        
        return cell!;
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        var place = placesList[indexPath.row];
        
        delegate?.placesListController(self, didSelectPlace: place);
    }
}
