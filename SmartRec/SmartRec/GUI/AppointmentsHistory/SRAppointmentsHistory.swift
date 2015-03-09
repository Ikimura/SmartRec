//
//  SRAppointmentsHistory.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/9/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRAppointmentsHistory: SRCommonViewController, SRAppointmentsDataSourceDelegate, UITableViewDelegate, UITableViewDataSource {

    private lazy var dataSource: SRAppointmentsDataSourceProtocol = {
        var temp = SRAppointmentsDataSource();
        temp.delegate = self;
        
        return temp;
    }();
    
    @IBOutlet var tableView: UITableView!;
    
    //MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.tableView.registerNib(UINib(nibName: "SRPlacesListTableViewCell", bundle: nil), forCellReuseIdentifier: kPlacesListCellIdentifier);
        
        fatalError("Update Data Source?");
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        fatalError("Show Details");
    }
    
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        fatalError("Retorurn Date in Human readable formate");
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return dataSource.numberOfSections();
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.numberOfItemInSection(section);
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: SRPlacesListTableViewCell? = tableView.dequeueReusableCellWithIdentifier(kPlacesListCellIdentifier) as? SRPlacesListTableViewCell;
        
        cell?.imageView?.cancelImageRequestOperation();
        
        if var appintment: SRCoreDataAppointment = dataSource.objectAtIndexPath(indexPath) as? SRCoreDataAppointment {
            
            fatalError("Not Emplemented");
        }
        
        return cell!;
    }
    
    //MARK: - SRAppointmentsDataSourceDelegate
    
    func dataSourceWillChangeContent(dataSource: SRAppointmentsDataSourceProtocol) {
        
        println("dataSourceWillChangeContent");
    }
    
    func dataSourceDidChangeContent(dataSource: SRAppointmentsDataSourceProtocol) {
        
        println("dataSourceDidChangeContent");
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
            
            if let strongSelf = self {
                
                strongSelf.tableView.reloadData();
            }
        });
    }
}
