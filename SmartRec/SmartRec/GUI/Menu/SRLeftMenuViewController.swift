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
        
    }
    
    //FIXME:
    
    @IBAction func menuButtonDidTap(sender: AnyObject) {
        
        if let btn = sender as? UIButton {
            
            var contentController: UIViewController? = menuItemInstancesByTag[btn.tag];
            
            if (contentController == nil) {
                
                var controlIdentifier = "";
                switch (btn.tag) {
                    
                case 0:
                    controlIdentifier = "contentViewController";
                    
                case 1:
                    controlIdentifier = "SRAppointmentsHistory";
                    
                default:
                    fatalError("No Such Menu Point");
                }
                
                contentController = self.storyboard?.instantiateViewControllerWithIdentifier(controlIdentifier) as? UIViewController;
                menuItemInstancesByTag[btn.tag] = contentController;
            }
            
            self.sideMenuViewController.setContentViewController(contentController, animated: true);
            self.sideMenuViewController.hideMenuViewController();
        }
    }
}
