//
//  SRBusyView.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/28/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit

class SRBusyView: UIView {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib();
        self.hideBusyView();
        self.activityIndicator.startAnimating();
    }

    deinit{
        
    }
    
    func showBusyView() {
        self.activityIndicator.hidden = false;
        self.setNeedsLayout();
    }

    func hideBusyView() {
        
        self.activityIndicator.hidden = true;
    }

    override func layoutSubviews() {
            if(self.superview != nil) {
                var rect: CGRect = self.frame;
                
                let selfH = Float(self.superview!.frame.size.height);
                let h = Float(rect.size.height);
                
                let y: Float = roundf((selfH - h) / 2.0);
                let x: Float = roundf((Float(self.superview!.frame.size.width) - Float(rect.size.width)) / 2.0)
                
                rect.origin.y = CGFloat(y);
                rect.origin.x = CGFloat(x);
                
                self.frame = rect;
            }
            super.layoutSubviews();
    }
}
