//
//  SRCalloutView.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/16/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import UIKit


protocol SRCalloutViewDelegate {
    func calloutViewAccessoryControlTapped(view: SRCalloutView, control: UIControl)
}

class SRCalloutView : UIView, UITextViewDelegate {

    var delegate: SRCalloutViewDelegate?;
    
    @IBOutlet weak var leftCaptureImage: UIImageView!
    @IBOutlet weak var rightCaptureImage: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var accessoryButton: UIButton!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.autoresizingMask = .None;
        self.hidden = true;
    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        self.initImages();
    }
    
    //MARK: - internal
    
    func setAccessory(accessory: Bool) {
        self.accessoryButton.hidden != accessory;
    }
    
    func showCalloutWithPosition(position: CGPoint) {
        
        self.hidden = false;
        self.setPosition(position, animated: false);
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 1.0;
        });
    }
    
    func hideCallout() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.alpha = 0.0;
            
            }) { (finished: Bool) -> Void in
                
                if (finished) {
                    self.hidden = true;
                }
        };
    }
    
    @IBAction func infoButtonPressed(sender: AnyObject) {
        delegate?.calloutViewAccessoryControlTapped(self, control: sender as UIControl);
    }
    
    func setPosition(position: CGPoint) {
        self.setPosition(position, animated: false);
    }
    
    func setPosition(position: CGPoint, animated: Bool) {
        
        var newPosition = CGPoint(x: position.x, y: position.y - (self.frame.size.height / 2.0));
        
        UIView.animateWithDuration(animated ? 0.4 : 0, animations: { () -> Void in
            self.center = newPosition;
        });
    }
    
    //MARK:- private
    
    private func initImages() {
        var inset = UIEdgeInsetsMake(9.0, 9.0, 13.0, 9.0);
        let leftCap = UIImage(named: "SRBubble_left")?.resizableImageWithCapInsets(inset);
        let rightCap = UIImage(named: "SRBubble_right")?.resizableImageWithCapInsets(inset);
        
        self.leftCaptureImage.image = leftCap;
        self.rightCaptureImage.image = rightCap;
    }
}