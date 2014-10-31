//
//  SRMovieListViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import AVFoundation

class SRMovieListViewController: SRCommonViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!;
    var allFiles: [VideoItem]!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allFiles = [VideoItem]();

        tableView.estimatedRowHeight = 74;
        tableView.rowHeight = UITableViewAutomaticDimension;
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
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
            cell.photoImage.image = item.thumbnailImage;
        }
        
        return cell;
    }
    
    // Override to support conditional editing of the table view.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true;
    }
    
    //TODO: FIX
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            //Delete the row from the data source
            let deleteItem: VideoItem = allFiles[indexPath.row];
            
            let filePath = self.formFilePathString(name: deleteItem.fileName);
            //
            if(NSFileManager.defaultManager().fileExistsAtPath(filePath)) {
                var err: NSError?;
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: &err);
                if (err == nil) {
                    NSLog("delete");
                    allFiles.removeAtIndex(indexPath.row);
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None);
                }
            }
            
        }
    }
    
    //TODO: FIX
    func formFilePathString(name fileName: String) -> String {
        
        let paths = NSSearchPathForDirectoriesInDomains(kFileDirectory, .UserDomainMask, true);
        var documentsDirectory = paths[0] as String;
        
        documentsDirectory += "/\(fileName)";
        
        NSLog(documentsDirectory);

        return documentsDirectory;
    }
    
    //TODO: FIX
    private func thumbnailImage(url: NSURL) -> UIImage {
        let sourceAsset:AVAsset = AVAsset.assetWithURL(url) as AVAsset;
        let duration: CMTime = sourceAsset.duration;
        
        let generator: AVAssetImageGenerator = AVAssetImageGenerator(asset: sourceAsset);
//
        var time: CMTime = sourceAsset.duration;
        time.value = 1000;

        let maxSize: CGSize = CGSizeMake(44, 64);
        generator.maximumSize = maxSize;
//        //Snatch a frame
        let frameRef: CGImageRef = generator.copyCGImageAtTime(time, actualTime: nil, error: nil);
        
        var resImage: UIImage = UIImage(CGImage: frameRef)!;
        
        let image: UIImage = UIImage(CGImage: resImage.CGImage, scale: 1.0, orientation: .Right)!;
        
        return image;
    }
    
    //TODO: FIX
    func updateData() {
        let paths = NSSearchPathForDirectoriesInDomains(kFileDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as String
        
        allFiles = [];
        var directoryContent: [AnyObject] = NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsDirectory, error: nil)!;
        if directoryContent.count > 0 {
            for str in directoryContent {
                
                NSLog("Files exist");
                
                if var name = str as? String {
                                        
                    if let url = NSURL.URL(directoryName: kFileDirectory, fileName: name) as NSURL! {
                        
                        var thmbImage: UIImage = self.thumbnailImage(url);
                        var tempItem = VideoItem(date: NSDate(), fileName: name, thumbnailImage: thmbImage);
                        allFiles.append(tempItem);
                    }
                }
            }
        }
        
        tableView.reloadData();
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        var filePath = "";
        var URL: NSURL? = nil;
        if let selectedCell = sender as? SRMovieTableViewCell {
            let indexPath: NSIndexPath = tableView.indexPathForCell(selectedCell)!;
            URL = NSURL.URL(directoryName: kFileDirectory, fileName: allFiles[indexPath.row].fileName)!;
        }
        
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "showVideoIdentifier" {
            if let showVideoVC = segue.destinationViewController as? SRShowVideoViewController {
                showVideoVC.fileURL = URL!;
            }
        }
    }


}
