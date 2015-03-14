//
//  SRAppointmentConfirmationViewController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/8/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import UIKit
import EventKit

enum SRConfirmationScreenType: Int {
    case Confirmation = 0;
    case Detailes = 1;
    case Notification = 2;
}

class SRAppointmentConfirmationViewController: SRCommonViewController, SRSocialSharingProtocol, UITextViewDelegate {
    
    var appointment: SRCoreDataAppointment?;
    var presantationType: SRConfirmationScreenType?;
   
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
//    @IBOutlet weak var cityZipLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    @IBOutlet weak var confirmationButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var pictureImageView: UIImageView!
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
        
        if (presantationType == .Notification) {
            
            let doneBar: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done:");
            self.navigationItem.leftBarButtonItem = doneBar;
        }
    }
    
    private func configureUI() {
        
        confirmationButton.setTitleShadowColor(UIColor.clearColor(), forState: .Selected);
        confirmationButton.setTitleColor(UIColor.whiteColor(), forState: .Selected);
        
        if (appointment != nil) {
            nameLabel.text = appointment!.place.name;
            addressLabel.text = appointment!.place.formattedAddress;
            
            var strDist = appointment!.place.distance.doubleValue.format(".3");
            addressLabel.text = addressLabel.text! + ", distance: \(strDist) km.";
            
            if var phoneNumber = appointment!.place.internalPhoneNumber as String! {
                
                phoneLabel.text = phoneNumber;
                
            } else {
                
                phoneLabel.text = appointment!.place.formattedPhoneNumber;
            }
            
            dateLabel.text = "\(appointment!.fireDate)";
            websiteLabel.text = appointment!.place.website;
//            cityZipLabel.text = appointment!.place.zipCity;
        }
        
        switch (presantationType!) {
        case .Confirmation:
            pictureImageView.hidden = true;
            
        case .Detailes:
            pictureImageView.hidden = false;
            self.loadPlaceImage();
            confirmationButton.hidden = true;
            calendarButton.hidden = true;
            notificationButton.hidden = true;
            
        case .Notification:
            
            pictureImageView.hidden = false;
            self.loadPlaceImage();
            confirmationButton.setTitle("Mark Arrived", forState: .Normal);
            calendarButton.hidden = true;
            notificationButton.hidden = true;
            
        default:
            println("we show confirmation");
        }
    }
    
    private func disableButtons() {
        
        calendarButton.enabled = false;
        notificationButton.enabled = false;
        confirmationButton.enabled = false;
    }
    
    //Mark: - handlers
    
    func done(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapShare(sender: AnyObject) {
        self.shareAppointmetnt();
    }
    
    @IBAction func addToCalendatDidTap(sender: AnyObject) {
        
        var btn = sender as UIButton;
        
        if (!btn.selected) {
            
            self.addAppointmentToCalendar();
            btn.selected = true;
            
        } else {
            
            self.removeAppointmentFromCalendar(byIdintifier: appointment!.calendarId!);
            btn.selected = false;
        }
    }
    
    @IBAction func trackLocationDidTap(sender: AnyObject) {
        
        var btn = sender as UIButton;
        btn.selected = !btn.selected;
        
        appointment!.locationTrack = !appointment!.locationTrack.boolValue;
    }
    
    @IBAction func finishDidTap(sender: AnyObject) {
        
        var btn = sender as UIButton;
        
        if (!btn.selected) {
            
            btn.selected = true;
            switch(presantationType!) {
            case .Confirmation:
                
                if (notesTextView.text.utf16Count > 0) {
                    
                    appointment!.note = notesTextView.text;
                }
                
                var error: NSError? = nil;
                appointment?.managedObjectContext?.save(&error);
                
                if (error != nil) {
                    
                    self.showAlertWith("Error", message: "\(error)");
                    
                } else {
                    
                    //TODO: localize
                    self.disableButtons();
                    self.showAlertWith("Succeed", message: "Appointment Was Successfully Added.");
                    println("save succeded");
                }
                
            case .Detailes:
                
                if (appointment != nil) {
                    
                    SRCoreDataAppointment.markArrivedAppointmnetWithId(appointment!.id);
                    
                } else {
                    
                    fatalError("No Such Appointment");
                }
                
            default:
                fatalError("No Souch Presantation Type");
            }
        }
    }
    
    //MARK: - Utils
    
    private func addAppointmentToCalendar() {
        
        var store: EKEventStore = EKEventStore();
        
        store.requestAccessToEntityType(EKEntityTypeEvent, completion: { [weak self] (granted: Bool, error: NSError!) -> Void in
            
            if (!granted) {
                return;
            }
            
            if let strongSelf = self {
                
                var event = EKEvent(eventStore: store);
                event.title = "CitiGuide. Visit \(strongSelf.appointment!.place.name)";
                event.location = strongSelf.appointment!.place.formattedAddress;
                
                if (strongSelf.appointment?.description != "") {
                    
                    event.notes = strongSelf.appointment!.note;
                }
                
                event.startDate = strongSelf.appointment!.fireDate;
                event.endDate = event.startDate.dateByAddingTimeInterval(60.0 * 30.0); //30 minute

                let alarm: EKAlarm = EKAlarm(absoluteDate: event.startDate.dateByAddingTimeInterval(60 * (-30)));
                
                event.addAlarm(alarm);
                event.calendar = store.defaultCalendarForNewEvents;
                
                var error: NSError?;
                store.saveEvent(event, span: EKSpanThisEvent, commit: true, error: &error);
                
                if (error == nil) {
                    
                    strongSelf.appointment!.calendarId = event.eventIdentifier;
                    
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
    
    private func loadPlaceImage() {
        
        if let photoReference = appointment!.place.photorReference as String! {
            
            var urlString = "\(kGooglePlacePhotoAPIURL)maxheight=\(kGooglePhotoMaxHeight)&photoreference=\(photoReference)&key=\(kGooglePlaceAPIKey)";
            urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!;
            
            let photoURL = NSURL(string: urlString);
            pictureImageView.setImageWithURL(photoURL, placeholderImage: UIImage(named: "image_placeholder"));
        }
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
        
//        var controller = UIActivityViewController(activityItems: [appointment!.place.name!, appointment!.description],
//                                          applicationActivities: nil);
        
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
//        self.presentViewController(controller, animated: true, completion: nil);
    }

}
