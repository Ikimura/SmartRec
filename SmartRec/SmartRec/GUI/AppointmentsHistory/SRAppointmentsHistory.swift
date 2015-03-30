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

        tableView.estimatedRowHeight = 74;
        tableView.rowHeight = UITableViewAutomaticDimension;

        self.automaticallyAdjustsScrollViewInsets = false;
    }
    
    override func setUpNavigationBar() {
        super.setUpNavigationBar();
        
        self.title = NSLocalizedString("history_screen_title", comment:"");
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false);
        
        var event: AnyObject = dataSource.objectAtIndexPath(indexPath);
        
        var detailsVC = self.storyboard?.instantiateViewControllerWithIdentifier("confirmationVC") as?SRAppointmentConfirmationViewController;
        detailsVC!.presentationType = .Detailes;
        detailsVC!.appointmentCD = event as? SRCoreDataAppointment;
        
        self.navigationController?.pushViewController(detailsVC!, animated: true);
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return dataSource.titleForHeaderInSection(section).capitalizedString;
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
            
            let atLS = NSLocalizedString("at_key", comment: "comment").capitalizedString;
            var date = NSDate(timeIntervalSince1970: appointment.fireDate)
            cell!.dateLabel?.text = "\(atLS) \(date.stringFromDateWithStringFormat(kTimeFormat))";
            
            var iconURLString = appointment.place.iconURL;
            iconURLString = iconURLString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!;
            
            let iconURL = NSURL(string: iconURLString);

            cell!.iconImage.setImageWithURL(iconURL, placeholderImage: UIImage(named: "image_placeholder"));

            cell!.indicatorImageView.tintColor = UIColor.greenColor();
            if (appointment.completed.boolValue) {
                
                cell!.indicatorImageView.image = UIImage(named: "cell_indicator_green_sel");
        
            } else if( NSDate().timeIntervalSince1970 > appointment.fireDate){
                
                cell!.indicatorImageView.image = UIImage(named: "warning");
        
            } else {
                
                cell!.indicatorImageView.image = UIImage(named: "cell_indicator_green_def");
            }
            
            if (appointment.calendarId != nil) {
                
                cell!.calendarImageView.image = UIImage(named: "calendar_sel");
                
            } else {
                
                cell!.calendarImageView.image = nil;
            }
        
            if (appointment.locationTrack.boolValue) {
                
                cell!.mapIndicatorImageView.image = UIImage(named: "alarm_sel");
        
            } else {
        
                cell!.mapIndicatorImageView.image = UIImage(named: "alarm_def");
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
                
                let result = SRCoreDataManager.sharedInstance.deleteEntity(deleteItem);

                if (deleteItem.locationTrack.boolValue) {
                    
                    appDelegate.eventsTracker.cancelLocationNotificationWith(deleteItem.id);
                }                
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
    
    func dataSourceDidUpdate(#object:AnyObject, atIndexPath indexPath: NSIndexPath?) {
        
    }
    
    func dataSourceDidDelete(#object:AnyObject, atIndexPath indexPath: NSIndexPath?) {
        
    }
    
    func dataSourceDidInsert(#object:AnyObject, atIndexPath indexPath: NSIndexPath?) {
        
    }
}
