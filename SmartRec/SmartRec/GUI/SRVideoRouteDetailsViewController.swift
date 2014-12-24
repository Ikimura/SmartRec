//
//  SRVideoRouteDetailsViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/22/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit
import CoreData

class SRVideoRouteDetailsViewController: SRCommonMapViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var videoFileNameLabel: UILabel!
    @IBOutlet weak var videoMarkLocationLabel: UILabel!
    @IBOutlet weak var videoMarkDateLabel: UILabel!
    @IBOutlet weak var videFileDurationLabel: UILabel!
    @IBOutlet weak var routeStartEndDateLabel: UILabel!
    
    var route: SRRoute?;
    var selectedVideoId: String?;
    
    private var selectedVideoMark: SRVideoMark?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let predicate = NSPredicate(format: "id == %@", selectedVideoId!);
        
        var temMarks = route?.videoMarks.filteredOrderedSetUsingPredicate(predicate!);
        
        var location: CLLocation?;
        if (temMarks != nil) {
            if var temp = temMarks?.firstObject as? SRVideoMark {
                selectedVideoMark = temp;
                location = CLLocation(latitude: selectedVideoMark!.latitude.doubleValue, longitude: selectedVideoMark!.longitude.doubleValue);
            }
        }
        
        self.setUpMapViewWith(location);
        
        self.makePolylineForRoute(route!);
        
        self.updateInformation();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
    }
    
    //MARK: - internal interface
    
   
    //MARK: - private interface
    
    private func updateInformation() {
        videoFileNameLabel.text = selectedVideoMark?.videoData?.fileName;
        //TODO:
        //change to geocoding
        videoMarkLocationLabel.text = "\(selectedVideoMark?.longitude.doubleValue), \(selectedVideoMark?.latitude.doubleValue)";
        let date: NSDate = NSDate(timeIntervalSinceReferenceDate: selectedVideoMark!.videoData!.date.doubleValue);
        videoMarkDateLabel.text = date.stringFromDateWithStringFormat("M/d/yyyy h:mma Z");
        //TODO:
        //set file duration
//        videFileDurationLabel.text
        
        //TODO:
        //set dates of first and last routePoint.date
//        routeStartEndDateLabel.text = 
    }
    
}
