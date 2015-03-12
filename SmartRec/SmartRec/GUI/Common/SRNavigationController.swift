//
//  SRNavigationController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 10/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit

class SRNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.applyDefaultStyle();
    }
    
    func applyDefaultStyle() {
        
        self.navigationBar.shadowImage = UIImage();
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationBar.tintColor = UIColor.whiteColor();
        self.navigationBar.barTintColor = UIColor(red: 0.0, green: 132.0 / 255.0, blue: 216.0 / 255.0, alpha: 1.0);
        self.navigationBar.opaque = true;
        self.navigationBar.translucent = false;
        // s etBackgroundImage(UIImage(named: "navigation_bar_bg_def"), forBarMetrics: .Default);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
