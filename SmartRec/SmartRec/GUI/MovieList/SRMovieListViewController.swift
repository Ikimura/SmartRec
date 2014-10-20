//
//  SRMovieListViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit

class SRMovieListViewController: SRCommonViewController, UITableViewDelegate, UITableViewDataSource {
    let reuseIdentifier = "movieCellidentifier";
    
    @IBOutlet var tableView: UITableView!;
    var allFiles: [VideoItem]!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        allFiles = [VideoItem]();
        
        for i in 0...4 {
            var tempDate = NSDate ();
            var tempItem = VideoItem();
            tempItem.date = tempDate;
            
            allFiles.append(tempItem);
        }
        // Do any additional setup after loading the view.
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
        var cell: SRMovieTableViewCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as SRMovieTableViewCell;
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .MediumStyle;
        dateFormatter.dateStyle = .MediumStyle;

        let str: String = dateFormatter.stringFromDate(allFiles[indexPath.row].date);
        
        cell.dateLabel.text = str;
        
        return cell;
    }

    /*

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
