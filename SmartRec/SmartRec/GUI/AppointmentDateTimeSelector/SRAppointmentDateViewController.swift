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

    var detailedPlace: SRCoreDataPlace?;
    
    private var datePicker: MGConferenceDatePicker?;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.setUpDatePicker();
    }
    
    override func setUpNavigationBar() {
        
        self.title = NSLocalizedString("date_selection_title", comment:"");
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
    }

    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var appointmentDate = datePicker?.valueOfSelectedDate();
        println("Selected Date \(appointmentDate)");
        
        if segue.identifier == kConfirmationSegueIdentifier {
            
            if let confVC = segue.destinationViewController as? SRAppointmentConfirmationViewController {
                
                var photoRef: [String]? = nil;
                if (detailedPlace!.photoReference != nil) {
                    
                    photoRef = [detailedPlace!.photoReference!];
                }
                
                var id = "\(detailedPlace!.placeId)\(appointmentDate!.timeIntervalSince1970)";
                var placeStruct = SRGooglePlace(placeId: detailedPlace!.placeId,
                    reference: detailedPlace!.reference,
                    lng: detailedPlace!.lat,
                    lat: detailedPlace!.lng,
                    iconURL: NSURL(string: detailedPlace!.iconURL),
                    name: detailedPlace!.name,
                    types: nil,
                    vicinity: detailedPlace!.vicinity,
                    formattedAddress: detailedPlace!.formattedAddress,
                    formattedPhoneNumber: detailedPlace!.formattedPhoneNumber,
                    internalPhoneNumber: detailedPlace!.internalPhoneNumber,
                    distance: detailedPlace!.distance,
                    photoReferences: photoRef,
                    website: detailedPlace!.website,
                    weekDayText: detailedPlace!.weekdayText);
                
                var appointment = SRAppointment(id: id, place: placeStruct, dateInSeconds: appointmentDate!.timeIntervalSince1970, locationTrack: false, description: "", calendarId: nil);
                
                confVC.presentationType = .Confirmation;
                confVC.appointmentST = appointment;
            }
        }
    }
}
