//
//  SRPlacesDetailsTableViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/7/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRPlacesDetailsTableViewController: SRCommonViewController, UITableViewDataSource, UITableViewDelegate, SRContinueTableViewCellDelegate {

    @IBOutlet var tableView: UITableView?;
    var place: SRGooglePlace?;
    
    private var dataSource: SRPlacesDetailsDataSourceProtocol?;
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        tableView?.registerNib(UINib(nibName: "SRPlacesListTableViewCell", bundle: nil), forCellReuseIdentifier: kPlacesListCellIdentifier);
        tableView?.registerNib(UINib(nibName: "SRPlaceGalaryCell", bundle: nil), forCellReuseIdentifier: kGalaryCellIdentifier);
        tableView?.registerNib(UINib(nibName: "SRContinueTableViewCell", bundle: nil), forCellReuseIdentifier: kContinueCellIdentifier);
        tableView?.registerNib(UINib(nibName: "SRPlaceWeekDayCell", bundle: nil), forCellReuseIdentifier: "weakday_cell_identifier");

        dataSource = SRPlacesDetailsDataSource(placeToDetaile: place!);
        
        self.showBusyView();
        dataSource?.loadData({ [weak self] () -> Void in
            
            if var strongSelf = self {

                strongSelf.hideBusyView();
                strongSelf.tableView?.reloadData();
            }
            
            }, errorBlock: { (error) -> Void in
        });
    }
    
    override func setUpNavigationBar() {
        
        self.title = NSLocalizedString("details_title", comment:"");

    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                return 103
            } else {
                return 126;
            }
        case 1: return 64;
        case 2:
            return 120;

        default:
            fatalError("Wrong Section Index");
        }
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
        
        if (indexPath.section == 1) {
            var cCell = tableView.dequeueReusableCellWithIdentifier(kContinueCellIdentifier) as? SRContinueTableViewCell;
            cCell?.delegate = self;
            cCell?.button.setTitle(NSLocalizedString("continue_cell_button", comment:""), forState: .Normal);
            
            cell = cCell;
            
        } else {
            
            var item = dataSource!.itemAtIndexPath(indexPath);
            
            switch (item) {
                
            case let place as SRGooglePlace:
                
                var dCell = tableView.dequeueReusableCellWithIdentifier(kPlacesListCellIdentifier) as? SRPlacesListTableViewCell;
                dCell!.iconImage.cancelImageRequestOperation();
                
                self.fillCell(dCell!, withData: place);
                cell = dCell;
                
            case is String:
                
                if (indexPath.section == 2) {
                    var gCell = tableView.dequeueReusableCellWithIdentifier(kGalaryCellIdentifier) as? SRPlaceGalaryCell;
                    gCell!.photoImageView.cancelImageRequestOperation();
                    
                    self.fillCell(gCell!, withData: item);
                    cell = gCell;
                    
                } else {
                    
                    var wCell = tableView.dequeueReusableCellWithIdentifier("weakday_cell_identifier") as? SRPlaceWeekDayCell;
                    wCell?.weekdayLabel.text = item as? String;
                    
                    cell = wCell;
                }
                
                println(item);
            default:
                fatalError("No Such Item");
            }
        }

        return cell!;
    }
    
    //MARK: - SRContinueTableViewCellDelegate
    
    func didSendCellContinueEvent(sender: AnyObject) {
        
        self.performSegueWithIdentifier(kSelectAppointmentDateSegueIdentifier, sender: sender);
    }
    
    //MARK: - Handler
    
    @IBAction func done(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func route(sender: AnyObject) {
        
        self.performSegueWithIdentifier(kRouteToPlaceSegueIdentifier, sender: sender);
    }
    
    //MARK: - Utils

    func fillCell(cell: UITableViewCell, withData data: Any) {
        
        switch (cell) {
            
        case var detCell as SRPlacesListTableViewCell:
            
            var place = data as SRGooglePlace;
            
            detCell.nameLabel.text = place.name;
            detCell.addressLabel.text = place.formattedAddress != nil ? place.formattedAddress!.capitalizedString : place.vicinity!.capitalizedString;
//            detCell.cityStateZipLabel.text = place.zipCity;
            
            detCell.iconImage.setImageWithURL(place.iconURL, placeholderImage: UIImage(named: "image_placeholder"));
            detCell.phoneLabel.text = place.internalPhoneNumber != nil ? place.internalPhoneNumber : place.formattedPhoneNumber;
            
            if (place.distance != nil) {
                
                var dist = Double(place.distance!);
                var strDist = dist.format(".3");
                var distReduction = NSLocalizedString("distance_reduction", comment:"")

                detCell.distanceLabel.text = "\(strDist), " + distReduction + ".";
                
            } else {
                
                detCell.distanceLabel.text = nil;
            }

            detCell.rightIndicator.image = nil;
            
        case var galaryCell as SRPlaceGalaryCell:
            var photoReference = data as String;
            
            var urlString = "\(kGooglePlacePhotoAPIURL)maxheight=\(kGooglePhotoMaxHeight)&photoreference=\(photoReference)&key=\(kGooglePlaceAPIKey)";
            urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!;
            
            let photoURL = NSURL(string: urlString);
            galaryCell.photoImageView.setImageWithURL(photoURL, placeholderImage: UIImage(named: "image_placeholder"));
            
        default:
            fatalError("No Such Cell");
        }
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        
        if (segue.identifier == kSelectAppointmentDateSegueIdentifier) {
            
            if let destVC = segue.destinationViewController as? SRAppointmentDateViewController {
                
                destVC.detailedPlace = dataSource!.itemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? SRGooglePlace;
            }
            
        } else if (segue.identifier == kRouteToPlaceSegueIdentifier) {
            
            if let navVC = segue.destinationViewController as? UINavigationController {
                
                if let destVC = navVC.viewControllers[0] as? SRPlaceRouteMapViewController {
                    
                    destVC.myCoordinate = appDelegate.currentLocation().coordinate;
                    destVC.targetCoordinate = CLLocationCoordinate2DMake(place!.lat, place!.lng);
                }
            }
        }
    }

}
