//
//  SRLeftMenuViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/9/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

enum SRMenuViewControllerMenuItem: Int {
    
    case SRMenuViewControllerMenuItemList = 0;
    case SRMenuViewControllerMenuItemHistory = 1
}


class SRLeftMenuViewController: SRCommonViewController {

    private var menuItemInstancesByTag = Dictionary<Int, UIViewController>();
    
    
    //MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAppointmentDetails:", name: "SHOW_APPOINTMENT", object: nil);
    }
        
    @IBAction func menuButtonDidTap(sender: AnyObject) {
        
        if let btn = sender as? UIButton {
            
            var contentController: UIViewController? = menuItemInstancesByTag[btn.tag];
            
            if (contentController == nil) {
                
                var controlIdentifier = "";
                switch (btn.tag) {
                    
                case 0:
                    controlIdentifier = "typesViewController";
                    
                case 1:
                    controlIdentifier = "appointmentsHistory";
                    
                case 2:
                    controlIdentifier = "videoRecorder";
                    
                case 3:
                    controlIdentifier = "recordedVideosHistory";
                    
                default:
                    fatalError("No Such Menu Point");
                }
                
                contentController = self.storyboard?.instantiateViewControllerWithIdentifier(controlIdentifier) as? UIViewController;
                menuItemInstancesByTag[btn.tag] = contentController;
            }
            
            self.sideMenuViewController.setContentViewController(SRNavigationController(rootViewController: contentController!), animated: true);
            self.sideMenuViewController.hideMenuViewController();
        }
    }
    
    func showAppointmentDetails(notification: NSNotification) {
        
        if let userInfo: [NSObject: AnyObject?] = notification.userInfo as [NSObject: AnyObject?]! {
            
            if let id = userInfo["uuid"] as? String {
                
                if var event  = SRCoreDataManager.sharedInstance.singleManagedObject("SRCoreDataAppointment", withUniqueField: id, inContext: SRCoreDataContextProvider.mainManagedObjectContext()) as? SRCoreDataAppointment {
                    
                    var detailsVC = self.storyboard?.instantiateViewControllerWithIdentifier("confirmationVC") as?SRAppointmentConfirmationViewController;
                    detailsVC!.presantationType = .Notification;
                    detailsVC!.appointment = event;
                    
                    self.presentViewController(SRNavigationController(rootViewController: detailsVC!), animated: true, completion: nil);

                }
            }
        }
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
}
