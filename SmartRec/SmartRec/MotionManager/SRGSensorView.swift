//
//  SRGSensorWidget.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 12/2/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit

//FIXME: - refactoring
class SRGSensorView: UIView {
    
    var borderColor: CGColor?;
    var bacgGroundColor: CGColor?;

    @IBOutlet weak var markerView: UIView!
    
    private let pixelsPerG = 25.0;
    private var yCenterConstraintInitialValue: CGFloat?;
    private var xCenterConstraintInitialValue: CGFloat?;
    
    private let markerSize: CGFloat = 20;

    override func awakeFromNib() {
        super.awakeFromNib();
        
        self.setUpConstraints();

        xCenterConstraintInitialValue = self.frame.size.width / 2.0;
        yCenterConstraintInitialValue = self.frame.size.height / 2.0;
        
        var markerLayer = CALayer();
        markerLayer.frame = CGRectMake(0, 0, markerSize, markerSize);
        markerLayer.cornerRadius = 10;
        markerLayer.borderWidth = 2;
        markerLayer.borderColor = UIColor.redColor().CGColor;
        
        markerView.layer.addSublayer(markerLayer);
    }
    
    private func setUpConstraints(){
        self.setTranslatesAutoresizingMaskIntoConstraints(false);

        let viewsDictionary: [NSObject: AnyObject] = ["widgetView": self];
        
        //view2
        let view2_constraint_H:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:[widgetView(150)]", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary);
        let view2_constraint_V:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:[widgetView(150)]", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary);
        
        self.addConstraints(view2_constraint_H);
        self.addConstraints(view2_constraint_V);
    }
    
    func moveMarkerAccrodinglyAccelerationZ(acceleraionX: Double, accelerationZ: Double) {
        
        markerView.frame.origin = CGPointMake(xCenterConstraintInitialValue! + CGFloat(acceleraionX * pixelsPerG) - 10, yCenterConstraintInitialValue! + CGFloat(accelerationZ * pixelsPerG) - 10);
    }
}
