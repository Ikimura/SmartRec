//
//  SRAppointmentDateViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/7/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRAppointmentDateViewController: SRCommonViewController, MGConferenceDatePickerDelegate {

    @IBOutlet weak var dateTimPickerView: UIView!
    
    var appointmentDate: NSDate?;
    var datePicker: MGConferenceDatePicker?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.title = "Date and Time";
        self.setUpDatePicker();
    }
    
    private func setUpDatePicker() {
        datePicker = MGConferenceDatePicker(frame: self.view.bounds);
        datePicker!.delegate = self;
        
        datePicker?.backgroundColor = UIColor.whiteColor();
        datePicker?.tintColor = UIColor(red: 218.0 / 255.0, green: 218.0 / 255.0, blue: 218.0 / 255.0, alpha: 1.0);
        
        dateTimPickerView.addSubview(datePicker!);
        datePicker?.setTranslatesAutoresizingMaskIntoConstraints(false);
        
        dateTimPickerView.addConstraint(NSLayoutConstraint(item: dateTimPickerView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: datePicker,
            attribute: .Top,
            multiplier: 1.0,
            constant: 0.0));
        
        dateTimPickerView.addConstraint(NSLayoutConstraint(item: dateTimPickerView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: datePicker,
            attribute: .Bottom,
            multiplier: 1.0,
            constant: 0.0));
        
        dateTimPickerView.addConstraint(NSLayoutConstraint(item: dateTimPickerView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: datePicker,
            attribute: .Leading,
            multiplier: 1.0,
            constant: 0.0));
        
        dateTimPickerView.addConstraint(NSLayoutConstraint(item: dateTimPickerView,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: datePicker,
            attribute: .Trailing,
            multiplier: 1.0,
            constant: 0.0));
    }
    
    func conferenceDatePicker(datePicker: MGConferenceDatePicker, saveDate date: NSDate) {
        appointmentDate = date;
    }

}
