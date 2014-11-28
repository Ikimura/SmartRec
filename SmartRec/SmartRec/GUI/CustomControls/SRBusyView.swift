//
//  SRBusyView.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/28/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit

class SRBusyView: UIView {
    
    @IBOutlet weak var activityIndicator: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib();
        self.hideBusyView();
        self.rotateLayerInfinite();
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

    func rotateLayerInfinite() {
        var rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation");
        rotation.fromValue = NSNumber(float: 0);
        rotation.toValue = NSNumber(float: Float(2.0 * M_PI));
        rotation.duration = 1.0;
        rotation.repeatCount = 10000000000000;
        
        self.activityIndicator.layer.removeAllAnimations();
        self.activityIndicator.layer.addAnimation(rotation, forKey: "Spin");
    }
}
