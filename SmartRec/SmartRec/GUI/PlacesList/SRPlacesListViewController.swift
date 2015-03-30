//
//  SRPlacesListViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/28/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

protocol SRPlacesListViewControllerDelegate {

    func placesListController(controller: SRPlacesListViewController, didSelectPlace place: SRCoreDataPlace);
}

class SRPlacesListViewController : SRCommonViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!;    
    var placesList: [SRCoreDataPlace] = [];
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
        tableView.estimatedRowHeight = 102;
        tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return placesList.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: SRPlacesListTableViewCell? = tableView.dequeueReusableCellWithIdentifier(kPlacesListCellIdentifier) as? SRPlacesListTableViewCell;
        
        cell?.imageView?.cancelImageRequestOperation();
        
        var place: SRCoreDataPlace = placesList[indexPath.row];
        cell!.nameLabel.text = "\(place.name)";
        
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
        
        var dist = Double(place.distance);
        var strDist = dist.format(".3");
        var distReduction = NSLocalizedString("distance_reduction", comment:"")

        cell!.distanceLabel.text = "\(strDist), " + distReduction + ".";
        var iconURL = NSURL(string: place.iconURL);
        cell!.iconImage.setImageWithURL(iconURL, placeholderImage: UIImage(named: "image_placeholder"));
        
        return cell!;
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        var place = placesList[indexPath.row];
        
        delegate?.placesListController(self, didSelectPlace: place);
    }
}
