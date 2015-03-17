//
//  SRAppointmentsHistory.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/9/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRAppointmentsHistory: SRCommonViewController, SRDataSourceDelegate, UITableViewDelegate, UITableViewDataSource {

    private lazy var dataSource: SRAppointmentsDataSourceProtocol = {
        var temp = SRAppointmentsDataSource();
        temp.delegate = self;
        
        return temp;
    }();
    
    @IBOutlet var tableView: UITableView!;
    
    //MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        dataSource.rebuildDataSet();
        
        tableView?.registerNib(UINib(nibName: "SRAppointmentHistoryCell", bundle: nil), forCellReuseIdentifier: "appHistory");

        tableView.estimatedRowHeight = 73;
        tableView.rowHeight = UITableViewAutomaticDimension;

        self.automaticallyAdjustsScrollViewInsets = false;
    }
    
    override func setUpNavigationBar() {
        super.setUpNavigationBar();
        
        self.title = "History";
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false);
        
        var event: AnyObject = dataSource.objectAtIndexPath(indexPath);
        
        var detailsVC = self.storyboard?.instantiateViewControllerWithIdentifier("confirmationVC") as?SRAppointmentConfirmationViewController;
        detailsVC!.presantationType = .Detailes;
        detailsVC!.appointment = event as? SRCoreDataAppointment;
        
        self.navigationController?.pushViewController(detailsVC!, animated: true);
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 73.0;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return dataSource.titleForHeaderInSection(section);
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return dataSource.numberOfSections();
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.numberOfItemInSection(section);
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: SRAppointmentHistoryCell? = tableView.dequeueReusableCellWithIdentifier("appHistory") as? SRAppointmentHistoryCell;
        
        cell?.iconImage?.cancelImageRequestOperation();
        
        if var appointment: SRCoreDataAppointment = dataSource.objectAtIndexPath(indexPath) as? SRCoreDataAppointment {
            
            cell!.nameLabel?.text = appointment.place.name;
            
            let atLS = NSLocalizedString("AT", comment: "comment");
            cell!.dateLabel?.text = "\(atLS) \(appointment.fireDate.stringFromDateWithStringFormat(kTimeFormat))";
            
            var iconURLString = appointment.place.iconURL;
            iconURLString = iconURLString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!;
            
            let iconURL = NSURL(string: iconURLString);

            cell!.iconImage.setImageWithURL(iconURL, placeholderImage: UIImage(named: "image_placeholder"));

            cell!.indicatorImageView.tintColor = UIColor.greenColor();
            if (appointment.completed.boolValue) {
                
                //TODO: resources
                cell!.indicatorImageView.image = UIImage(named: "cell_indicator_sel");
        
            } else if( NSDate().timeIntervalSince1970 > appointment.fireDate.timeIntervalSince1970){
                
                //TODO: resources
//                cell!.indicatorImageView.image = nil;
                cell!.indicatorImageView.image = UIImage(named: "cell_indicator_sel");
        
            } else {
                
                cell!.indicatorImageView.image = UIImage(named: "cell_indicator_def");
            }
        
            if (appointment.locationTrack.boolValue) {
                
                cell!.mapIndicatorImageView.image = UIImage(named: "map_annotation_conf");
        
            } else {
        
                cell!.mapIndicatorImageView.image = nil;
            }
        }
        
        return cell!;
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true;
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (editingStyle == .Delete) {
            
            //Delete the row from the data source
            if let deleteItem = dataSource.objectAtIndexPath(indexPath) as? SRCoreDataAppointment {
                
                let result = appDelegate.coreDataManager.deleteEntity(deleteItem);
            }
        }
    }
    
    //MARK: - SRAppointmentsDataSourceDelegate
    
    func dataSourceDidChangeDataSet(dataSource: SRDataSource) {
    
        println("dataSourceDidChangeContent");
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
            
            if let strongSelf = self {
                
                strongSelf.tableView.reloadData();
            }
        });
    }
}
