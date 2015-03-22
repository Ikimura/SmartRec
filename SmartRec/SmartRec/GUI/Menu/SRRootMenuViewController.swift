//
//  SRRootMenuViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/9/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRRootMenuViewController : RESideMenu {

    override func awakeFromNib() {
        super.awakeFromNib();

        self.leftMenuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("leftMenuController") as UIViewController;
        self.contentViewController = SRNavigationController(rootViewController: self.storyboard?.instantiateViewControllerWithIdentifier("typesViewController") as UIViewController);
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.view.backgroundColor = UIColor.clearColor();
        self.menuPreferredStatusBarStyle = .LightContent;
        self.contentViewShadowColor = UIColor.blueColor();
        self.contentViewShadowOffset = CGSizeMake(0, 0);
        self.contentViewShadowOpacity = 0.1;
        self.contentViewShadowRadius = 2;
        self.contentViewShadowEnabled = true;
    }
    
    func rollbackToContentViewController() {
            
        self.contentViewController.presentedViewController!.dismissViewControllerAnimated(true, completion: nil);
        
        if (self.contentViewController is SRNavigationController) {
            
            let vc = self.contentViewController as SRNavigationController;
            vc.popToRootViewControllerAnimated(true);
        }
    }
}