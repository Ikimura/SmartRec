//
//  SRAppointmentConfirmationViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/8/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import UIKit
import EventKit

class SRAppointmentConfirmationViewController: SRCommonViewController {
    
    var appointment: SRAppointment?;
   
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.configureUI();
    }
    
    //MARK: - Configuration
    
     override func setUpNavigationBar() {
        
        self.title = "LOGO"
        let shareBar: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem:.Action, target: self, action: Selector("didTapShare:"));
        
        self.navigationItem.rightBarButtonItem = shareBar;
    }
    
    private func configureUI() {
        
        nameLabel.text = appointment!.place.name!;
        addressLabel.text = appointment!.place.formatedAddres!;
        phoneLabel.text = appointment!.place.formattedPhoneNumber!;
    }
    
    //Mark: - handlers
    
    func didTapShare(sender: AnyObject) {
        fatalError("Sharing Is Not Implemented");
    }
    
    @IBAction func addToCalendatDidTap(sender: AnyObject) {
        
        var btn = sender as UIButton;
        
        if (!btn.selected) {
            
            self.addAppointmentToCalendar(appointment!);
            btn.selected = true;
            
        } else {
            
            self.removeAppointmentFromCalendar(byIdintifier: appointment!.calendarId!);
            btn.selected = false;
        }
    }
    
    @IBAction func trackLocationDidTap(sender: AnyObject) {
        
        fatalError("Location Tracking Is Not Implemented!");
    }
    
    @IBAction func finishDidTap(sender: AnyObject) {
        
        //TODO: before save check description text field
        fatalError("Save Logic Is Not Emplemeted");
    }
    
    //MARK: - Utils
    
    private func addAppointmentToCalendar(appointment: SRAppointment) {
        
        var store: EKEventStore = EKEventStore();
        
        store.requestAccessToEntityType(EKEntityTypeEvent, completion: { [weak self] (granted: Bool, error: NSError!) -> Void in
            
            if (!granted) {
                return;
            }
            
            if let strongSelf = self {
                
                var event = EKEvent(eventStore: store);
                event.title = "CitiGuide. Visit \(strongSelf.appointment!.place.name!)";
                event.location = strongSelf.appointment!.place.formatedAddres;
                
                if (strongSelf.appointment?.description != "") {
                    
                    event.notes = strongSelf.appointment!.description;
                }
                
                event.startDate = NSDate(timeIntervalSince1970: strongSelf.appointment!.dateInSeconds);
                event.endDate = event.startDate.dateByAddingTimeInterval(60.0 * 30.0); //30 minute

                let alarm: EKAlarm = EKAlarm(absoluteDate: event.startDate.dateByAddingTimeInterval(60 * (-30)));
                
                event.addAlarm(alarm);
                event.calendar = store.defaultCalendarForNewEvents;
                
                var error: NSError?;
                store.saveEvent(event, span: EKSpanThisEvent, commit: true, error: &error);
                
                if (error == nil) {
                    
                    strongSelf.appointment!.setCalendarId(event.eventIdentifier);
                    
                    strongSelf.showAlertWith("Message", message: "Event Was Succesfully Added To Calendar!");
                }
                
            }
        });
    }
    
    private func removeAppointmentFromCalendar(byIdintifier id: String) {
        
        var store: EKEventStore = EKEventStore();
        
        store.requestAccessToEntityType(EKEntityTypeEvent, completion: { [weak self] (granted: Bool, error: NSError!) -> Void in
            
            if (!granted) {
                return;
            }
            
            if let strongSelf = self {
                
                var eventToRemove: EKEvent? = store.eventWithIdentifier(id);
                
                if (eventToRemove != nil) {
                    
                    var error: NSError?;
                    
                    store.removeEvent(eventToRemove, span: EKSpanThisEvent, commit: true, error: &error);
                    
                    if (error == nil) {
                        
                        strongSelf.showAlertWith("Message", message: "Event Was Deleted From Calendar!")
                        
                    }
                }
            }
        });
    }
    
}
