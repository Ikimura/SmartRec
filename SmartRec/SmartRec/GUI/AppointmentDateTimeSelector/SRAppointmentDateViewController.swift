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
    var detailedPlace: SRGooglePlace?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.title = "Date and Time";
        self.setUpDatePicker();
    }
    
    override func setUpNavigationBar() {
        
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
    
    //MARK: - MGConferenceDatePickerDelegate
    
    func conferenceDatePicker(datePicker: MGConferenceDatePicker, saveDate date: NSDate) {
        println("conferenceDatePicker");
        appointmentDate = date;
        println("Selected Date \(appointmentDate)");

    }

    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        appointmentDate = datePicker?.valueOfSelectedDate();
        println("Selected Date \(appointmentDate)");
        
        if segue.identifier == kConfirmationSegueIdentifier {
            
            if let confVC = segue.destinationViewController as? SRAppointmentConfirmationViewController {
                
                var id = "\(detailedPlace!.placeId)\(appointmentDate!.timeIntervalSince1970)";
                
                var appointment = SRAppointment(id: id, place: detailedPlace!, dateInSeconds: appointmentDate!.timeIntervalSince1970, locationTrack: false, description: "", calendarId: nil);
                
                confVC.presentationType = .Confirmation;
                confVC.appointmentST = appointment;
            }
        }
    }
}
