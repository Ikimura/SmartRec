//
//  UIViewExtensions.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/20/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import UIKit

extension UIView {
    class func viewFromNibName(name: String) -> UIView? {
        let views = NSBundle.mainBundle().loadNibNamed(name, owner: nil, options: nil)
        return views.first as? UIView
    }
}