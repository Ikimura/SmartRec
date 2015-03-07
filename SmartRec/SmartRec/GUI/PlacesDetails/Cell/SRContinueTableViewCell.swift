//
//  SRContinueTableViewCell.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/7/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

protocol SRContinueTableViewCellDelegate {
    
    func didSendCellContinueEvent(sender: AnyObject);
}

class SRContinueTableViewCell: UITableViewCell {
    
    var delegate: SRContinueTableViewCellDelegate?;
    
    @IBAction func didTapButton(sender: AnyObject) {
        
        delegate?.didSendCellContinueEvent(sender);
    }
}
