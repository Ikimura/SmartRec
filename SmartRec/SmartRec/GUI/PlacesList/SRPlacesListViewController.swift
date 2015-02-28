//
//  SRPlacesListViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/28/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRPlacesListViewController : SRCommonViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!;    
    var placesList: [SRGooglePlace]?;
    var types: [(name: String, value: String)]?;
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //FIXME: - move to constatnt check xib
        self.tableView.registerNib(UINib(nibName: "SRPlacesListTableViewCell", bundle: nil), forCellReuseIdentifier: kPlacesListCellIdentifier);
        
        var inset: UIEdgeInsets = UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController!.navigationBar.frame), 0, 0, 0);
        tableView.scrollIndicatorInsets = inset;
        tableView.contentInset = inset;
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return placesList!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: SRPlacesListTableViewCell? = tableView.dequeueReusableCellWithIdentifier(kPlacesListCellIdentifier) as? SRPlacesListTableViewCell;
        
        var place: SRGooglePlace = placesList![indexPath.row];
        cell!.nameLabel.text = "\(place.name!),";
        cell!.phoneLabel.text = place.formattedPhoneNumber;
        cell!.addressLabel.text = place.formatedAddres;
        
//        cell!.cityStateZipLabel.text = "\(place.city), \(place.state) \(place.zipCode)";
//        cell!.distanceLabel.text = place.distance;
        
        return cell!;
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        //TODO: - show information
    }
}
