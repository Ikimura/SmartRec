//
//  SRRoundedButton.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/22/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import UIKit

class SRRoundedButton: UIButton {
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func drawRect(rect: CGRect) {
        updateLayerProperties()
    }
    
    func updateLayerProperties() {
        
        layer.masksToBounds = true;
        layer.cornerRadius = 24.0;
    }
    
}
