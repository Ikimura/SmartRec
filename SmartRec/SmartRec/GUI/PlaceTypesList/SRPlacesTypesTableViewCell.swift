//
//  SRPlacesTableViewCell.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/26/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRPlacesTypesTableViewCell: UITableViewCell {

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var pictureImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated);
        
        if (!self.selected) {
            
            if (highlighted) {
                pictureImage.image = UIImage(named: "cell_indicator_sel");
            } else {
                pictureImage.image = UIImage(named: "cell_indicator_def");
            }
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated);
        
        if (selected) {
            pictureImage.image = UIImage(named: "cell_indicator_sel");
        } else {
            pictureImage.image = UIImage(named: "cell_indicator_def");

        }
    }
}
