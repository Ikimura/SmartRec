//
//  SRCommonViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit

class SRCommonViewController: UIViewController, SRAirDropSharingProtocol {
    
    private var busyView: SRBusyView?;
    private var busyCounter: Int = 0;
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;

    var fileURL: NSURL?;

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setUpNavigationBar();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - public interface
    
    func setUpNavigationBar() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_btn"), style: .Plain, target: self, action: "menuAction:");
    }
    
    func showAlertWith(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showBusyView() {
        busyCounter++;
        
        if (self.busyView == nil) {
            self.busyView = SRBusyView.viewFromNibName(kBusyViewNibName) as? SRBusyView;
            
            self.view.addSubview(self.busyView!);
        }
        else {
            self.view.bringSubviewToFront(self.busyView!);
        }
        self.busyView!.showBusyView();
    }
    
    func hideBusyView() {
        if (--busyCounter <= 0) {
            busyCounter = 0;
            self.busyView!.hideBusyView();
            self.busyView!.removeFromSuperview();
            self.busyView = nil;
        }
    }

    //pragma mark - handler
    
    @IBAction func shareItemDidTap(sender: AnyObject) {
        self.prepareItemToShare();
    }
    
    func prepareItemToShare() {
        
    }
    
    func menuAction(sender: AnyObject) {
        
        self.presentLeftMenuViewController(self);
    }
    
    //pragma mark - SRAirDropSharingProtocol
    
    func shareVideoItem() {
        var objectsToShare = [self.fileURL!];
        
        var controller = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil);
        var excludedActivities = [
            UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
            UIActivityTypePostToWeibo, UIActivityTypeMessage, UIActivityTypeMail,
            UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
            UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo
        ];
        
        controller.excludedActivityTypes = excludedActivities;
        
        // Present the controller
        self.presentViewController(controller, animated: true, completion: nil);

    }
    
    
}
