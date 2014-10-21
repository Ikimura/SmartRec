//
//  SRMovieListViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit

class SRMovieListViewController: SRCommonViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!;
    var allFiles: [VideoItem]!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allFiles = [VideoItem]();

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updateData();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int = 0;
        if section == 0 {
            rows = allFiles.count;
        }
        return rows;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: SRMovieTableViewCell = tableView.dequeueReusableCellWithIdentifier("movieCellidentifier", forIndexPath: indexPath) as SRMovieTableViewCell;

        if let item = allFiles[indexPath.row] as VideoItem! {
            cell.dateLabel.text = item.fileName;
        }
        
        return cell;
    }
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            //Delete the row from the data source
            
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            var documentsDirectory = paths[0] as String
            
            let deleteItem: VideoItem = allFiles[indexPath.row];
            documentsDirectory += "/";
            documentsDirectory += deleteItem.fileName;
            
            
            NSLog(documentsDirectory);
            //
            if(NSFileManager.defaultManager().fileExistsAtPath(documentsDirectory)) {
                
                var err: NSError?;
                NSFileManager.defaultManager().removeItemAtPath(documentsDirectory, error: &err);
                if (err == nil) {
                    NSLog("delete");
                    allFiles.removeAtIndex(indexPath.row);
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade);
                }
            }
            
        }
    }

    
    func updateData() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as String
        
        var directoryContent: [AnyObject] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsDirectory, error: nil)!;
        if directoryContent.count > 0 {
            for str in directoryContent {
                
                NSLog("Files exist");
                
                var tempItem = VideoItem();
                if let name = str as? String {
                    tempItem.fileName = name;
                    allFiles.append(tempItem);
                }
                
            }
        }
        
        tableView.reloadData();
    }
    
    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
