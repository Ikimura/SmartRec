//
//  SRMovieListViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class SRMovieListViewController: SRCommonViewController, SRDataSourceDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private var tableView: UITableView!;

    private lazy var fileManager: NSFileManager = {
        return NSFileManager.defaultManager();
    }();
    
    private lazy var dataSource: SRAppointmentsDataSourceProtocol = {
        var temp = SRRecordedRoutesDataSource();
        temp.delegate = self;
        
        return temp;
    }();
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 74;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        dataSource.rebuildDataSet();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setUpNavigationBar() {
        super.setUpNavigationBar();
        
        self.title = NSLocalizedString("my_videos", comment:"");
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
        var cell: SRMovieTableViewCell = tableView.dequeueReusableCellWithIdentifier(kMovieListCellIdentifier, forIndexPath: indexPath) as SRMovieTableViewCell;

        if let item = dataSource.objectAtIndexPath(indexPath) as? SRCoreDataRouteVideoPoint {
            
            if var videoDataItem = item.videoData {
                println(videoDataItem.fileName);
                cell.dateLabel.text = videoDataItem.fileName;
                
                var timeSec = NSLocalizedString("time_seconds_reduction", comment: "");
                var durStr = videoDataItem.duration.format(".2");
                cell.locationLabel.text = "\(durStr) \(timeSec).";
            }

            if let image = UIImage(data: item.thumbnailImage)? {
                cell.photoImage.image = image;
            } else {
                println("No Image");
            }
        }
        
        return cell;
    }
    
    //MARK: - UITableViewDelegate

    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true;
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (editingStyle == .Delete) {
            
            //Delete the row from the data source
            if let deleteItem = dataSource.objectAtIndexPath(indexPath) as? SRCoreDataRouteVideoPoint {
                
                if var videoDataItem = deleteItem.videoData {
                    let url = NSURL.URL(directoryName: kFileDirectory, fileName: "\(videoDataItem.fileName)\(kFileExtension)");
                    println("Debug. URL: \(url!)");
                    println("Debug. PATH: \(url!.path!)");

                    if self.fileManager.fileExistsAtPath(url!.path!) {
                        let result = fileManager.removeItemWithURL(url!);
                        
                        switch result {
                        case .Success(let quotient):
                            println("Debug. File deleted!");
                            
                            let result = SRCoreDataManager.sharedInstance.deleteEntity(deleteItem);
                            switch result {
                            case .Success(let quotient):
                                println("Debug. File deleted!");
                            case .Failure(let error):
                                println("Debug. Deleting failed");
                            }
                            
                        case .Failure(let error):
                            println("Debug. Deleting failed");
                        }
                    } else {
                        println("Debug. File doesn't exist");
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
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
    //MARK: - Handler
    
    func didTapMap(sender: AnyObject) {
        
        fatalError("Show Map")
        
    }
    
    //MARK: - Navigation
        
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        var selectedVideoMark: SRCoreDataRouteVideoPoint?;
        if let selectedCell = sender as? SRMovieTableViewCell {
            let indexPath: NSIndexPath = tableView.indexPathForCell(selectedCell)!;
            if let selectedItem = dataSource.objectAtIndexPath(indexPath) as? SRCoreDataRouteVideoPoint {
                selectedVideoMark = selectedItem;
            }
        }
        
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == kDisplayVideoRouteDetailsSegueIdentifier_1 {
            
            if let routeVideoDetailsVC = segue.destinationViewController as? SRRouteMapViewController {
                
                routeVideoDetailsVC.route = selectedVideoMark?.route;
                routeVideoDetailsVC.selectedVideoMark = selectedVideoMark;
            }
        }
    }

}
