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
        
        if (self.navigationController != nil) {
            
            var inset: UIEdgeInsets = UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController!.navigationBar.frame), 0, 0, 0);
            tableView.scrollIndicatorInsets = inset;
            tableView.contentInset = inset;
        }
        self.automaticallyAdjustsScrollViewInsets = false;
    }
    
    override func setUpNavigationBar() {
        super.setUpNavigationBar();
        
        self.title = "History";
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var event: AnyObject = dataSource.objectAtIndexPath(indexPath);
        
        var detailsVC = self.storyboard?.instantiateViewControllerWithIdentifier("confirmationVC") as?SRAppointmentConfirmationViewController;
        detailsVC!.presantationType = .Detailes;
        detailsVC!.appointment = event as? SRCoreDataAppointment;
        
        self.navigationController?.pushViewController(detailsVC!, animated: true);
    }
    
    //MARK: - UITableViewDataSource
    
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
        
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("appHistory") as? UITableViewCell;
        
        cell?.imageView?.cancelImageRequestOperation();
        
        if var appintment: SRCoreDataAppointment = dataSource.objectAtIndexPath(indexPath) as? SRCoreDataAppointment {
            
            cell?.textLabel?.text = appintment.place.name;
            cell?.detailTextLabel?.text = "\(appintment.fireDate)";
            
            //TODO: use custom cell
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
