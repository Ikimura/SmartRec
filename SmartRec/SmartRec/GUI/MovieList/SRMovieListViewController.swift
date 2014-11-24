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

class SRMovieListViewController: SRCommonViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet private var tableView: UITableView!;
    
    private lazy var fetchedResultController: NSFetchedResultsController = {
        
        var tempFetchedRC: NSFetchedResultsController?;
        
        let entity: NSEntityDescription = NSEntityDescription.entityForName(kManagedObjectVideoMark, inManagedObjectContext: SRCoreDataManager.sharedInstance.mainObjectContext)!;
        let sort = NSSortDescriptor(key: "videoData.date", ascending: true)

        var fetchRequest: NSFetchRequest = NSFetchRequest();
        fetchRequest.entity = entity;
        fetchRequest.sortDescriptors = [sort];
        
        tempFetchedRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: SRCoreDataManager.sharedInstance.mainObjectContext, sectionNameKeyPath: nil, cacheName: nil);
        tempFetchedRC?.delegate = self;
        
        return tempFetchedRC!;
    }();
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 74;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        var error: NSError? = nil;
        if !self.fetchedResultController.performFetch(&error) {
            NSLog("Unresolved error %@", error!);
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates();
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert: self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade);
        case .Delete: self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade);
        default:
            println("Error!");
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        let tblView = self.tableView;
        
        switch type {
        case .Insert: tblView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade);
        case .Delete: tblView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade);
        case .Update: tblView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade);
        case .Move:
            tblView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade);
            tblView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade);
        default:
            println("Error!");
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates();
    }

    //MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultController.sections!.count;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: NSFetchedResultsSectionInfo = self.fetchedResultController.sections![section] as NSFetchedResultsSectionInfo;

        return rows.numberOfObjects;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: SRMovieTableViewCell = tableView.dequeueReusableCellWithIdentifier(kMovieListCellIdentifier, forIndexPath: indexPath) as SRMovieTableViewCell;

        if let item = self.fetchedResultController.fetchedObjects![indexPath.row] as? SRVideoMark {
            let videoDataItem = item.videoData
                
            cell.dateLabel.text = videoDataItem.fileName;
            if let image = UIImage(data: item.thumnailImage)? {
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
    
    //TODO: FIX
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            //Delete the row from the data source
            if let deleteItem = self.fetchedResultController.fetchedObjects![indexPath.row] as? SRVideoMark {
                
                let managedObjectContext = deleteItem.managedObjectContext!;
                managedObjectContext.deleteObject(deleteItem)
                
                /* save `NSManagedObjectContext`
                deletes model from the persistent store (SQLite DB) */
                var e: NSError?;
                if (!managedObjectContext.save(&e)) {
                    println("cancel error: \(e!.localizedDescription)")
                }
            }
        }
    }
        
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        var url: NSURL?;
        if let selectedCell = sender as? SRMovieTableViewCell {
            let indexPath: NSIndexPath = tableView.indexPathForCell(selectedCell)!;
            if let selectedItem = self.fetchedResultController.fetchedObjects![indexPath.row] as? SRVideoMark {
                url = NSURL.URL(directoryName: kFileDirectory, fileName: "\(selectedItem.videoData.fileName)\(kFileExtension)")!;
            }
        }
        
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == kShowMovieSegueIdentifier {
            if let showVideoVC = segue.destinationViewController as? SRShowVideoViewController {
                showVideoVC.fileURL = url!;
            }
        }
    }


}
