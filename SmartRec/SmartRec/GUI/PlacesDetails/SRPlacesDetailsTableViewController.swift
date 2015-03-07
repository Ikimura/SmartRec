//
//  SRPlacesDetailsTableViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/7/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRPlacesDetailsTableViewController: SRCommonViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView?;
    var place: SRGooglePlace?;
    
    private var dataSource: SRPlacesDetailsDataSourceProtocol?;

    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        tableView?.registerNib(UINib(nibName: "SRPlacesListTableViewCell", bundle: nil), forCellReuseIdentifier: kPlacesListCellIdentifier);
        tableView?.registerNib(UINib(nibName: "SRPlaceGalaryCell", bundle: nil), forCellReuseIdentifier: kGalaryCellIdentifier);

        dataSource = SRPlacesDetailsDataSource(placeToDetaile: place!);
        
        self.showBusyView();
        dataSource?.loadData({ [weak self] () -> Void in
            
            if let strongSelf = self {
                
                strongSelf.hideBusyView();
                strongSelf.tableView?.reloadData();
            }
            
            }, errorBlock: { (error) -> Void in
        });
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if (indexPath.section == 0) {
            
            return 80;
            
        } else if (indexPath.section == 1) {
            
            return 120;
        }
        
        return 0;
    }
    
    //MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if dataSource == nil {
            return 0;
        }
        
        return dataSource!.numberOfSections();
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource!.numberItemsInSection(section);
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell?;
        
        var item = dataSource!.itemAtIndexPath(indexPath);
        
        switch (item) {
            
        case let place as SRGooglePlace:
            
            var dCell = tableView.dequeueReusableCellWithIdentifier(kPlacesListCellIdentifier) as? SRPlacesListTableViewCell;
            dCell!.iconImage.cancelImageRequestOperation();

            self.fillCell(dCell!, withData: place);
            cell = dCell;
            
        case is String:
            
            var gCell = tableView.dequeueReusableCellWithIdentifier(kGalaryCellIdentifier) as? SRPlaceGalaryCell;
            gCell!.photoImageView.cancelImageRequestOperation();
            
            self.fillCell(gCell!, withData: item);
            cell = gCell;
            
            println(item);
        default:
            fatalError("No Such Item");
        }

        return cell!;
    }
    
    //MARK: - Utils
    
    @IBAction func done(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fillCell(cell: UITableViewCell, withData data: Any) {
        
        switch (cell) {
            
        case var detCell as SRPlacesListTableViewCell:
            
            var place = data as SRGooglePlace;
            
            detCell.nameLabel.text = place.name;
            detCell.addressLabel.text = place.formatedAddres != nil ? place.formatedAddres : place.vicinity;
            detCell.cityStateZipLabel.text = place.zipCity;
            
            detCell.iconImage.setImageWithURL(place.iconURL, placeholderImage: UIImage(named: "image_placeholder"));
            detCell.phoneLabel.text = place.internalPhoneNumber != nil ? place.internalPhoneNumber : place.formattedPhoneNumber;
            
            if (place.distance == nil) {
                
                place.addDistance(CLLocation.distanceBetweenLocation(CLLocationCoordinate2DMake(place.lat, place.lng), secondLocation: SRLocationManager.sharedInstance.currentLocation()!.coordinate));
            }
            var dist = Double(place.distance!);
            var strDist = dist.format(".3");            
            detCell.distanceLabel.text = "\(strDist), km";
            
        case var galaryCell as SRPlaceGalaryCell:
            var photoReference = data as String;
            
            var urlString = "\(kGooglePlacePhotoAPIURL)maxheight=\(kGooglePhotoMaxHeight)&photoreference=\(photoReference)&key=\(kGooglePlaceAPIKey)";
            urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!;
            
            let photoURL = NSURL(string: urlString);
            galaryCell.photoImageView.setImageWithURL(photoURL, placeholderImage: UIImage(named: "image_placeholder"));
            
        default:
            fatalError("No Such Cell");
        }
    }
}
