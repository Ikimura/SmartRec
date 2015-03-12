//
//  SRAppointmentConfirmationViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/8/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import UIKit
import EventKit

class SRAppointmentConfirmationViewController: SRCommonViewController, SRSocialSharingProtocol, UITextViewDelegate {
    
    var appointment: SRAppointment?;
   
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
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
        addressLabel.text = appointment!.place.formattedAddress!;
        phoneLabel.text = appointment!.place.formattedPhoneNumber;
        dateLabel.text = "\(NSDate(timeIntervalSince1970: appointment!.dateInSeconds))";
    }
    
    //Mark: - handlers
    
    func didTapShare(sender: AnyObject) {
        self.shareAppointmetnt();
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
        
        var btn = sender as UIButton;
        btn.selected = !btn.selected;
        
        appointment!.locationTrack = !appointment!.locationTrack;
    }
    
    @IBAction func finishDidTap(sender: AnyObject) {
        
        if (notesTextView.text.utf16Count > 0) {
            
            appointment?.description = notesTextView.text;
        }
        
        appDelegate.coreDataManager.insertAppointmentEntity(appointment!, complitionBlock: { [weak self](error) -> Void in
            
            if let strongSelf = self {
                
                if (error == nil) {
                    
                    //TODO: roll back to root vc
                    
                } else {
                    
                    strongSelf.showAlertWith("Error", message: "\(error)");
                }
            }
        });
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
                event.location = strongSelf.appointment!.place.formattedAddress;
                
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
    
    //MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        textView.text = "";
        println("textViewShouldBeginEditing");
        return true;
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        println("shouldChangeTextInRange");
        
        if (textView.text.utf16Count == 0) {
            
            textView.text = "Leave your notes...";
        }
        
        return true;
    }
    
    //MARK: - SRSocialSharingProtocol

    func shareAppointmetnt() {
        
        var controller = UIActivityViewController(activityItems: [appointment!.place.name!, appointment!.description],
                                          applicationActivities: nil);
        
//        var excludedActivities = [
//            UIActivityTypeAirDrop,
//            UIActivityTypePostToWeibo, UIActivityTypeMessage,
//            UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
//            UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
//            UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
//            UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo
//        ];
//        
//        controller.excludedActivityTypes = excludedActivities;
        
        // Present the controller
        self.presentViewController(controller, animated: true, completion: nil);
    }

}
