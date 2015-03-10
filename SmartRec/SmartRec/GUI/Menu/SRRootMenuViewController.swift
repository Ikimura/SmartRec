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
        
        self.view.backgroundColor = UIColor.greenColor();
        self.menuPreferredStatusBarStyle = .LightContent;
        self.contentViewShadowColor = UIColor.blackColor();
        self.contentViewShadowOffset = CGSizeMake(0, 0);
        self.contentViewShadowOpacity = 0.6;
        self.contentViewShadowRadius = 5;
        self.contentViewShadowEnabled = true;
    }
}