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
    @IBOutlet weak var textViewTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var pictureImageTopLayoutConstraint: NSLayoutConstraint!
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.configureUI();
    }
    
    override func viewWillAppear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide:", name: UIKeyboardDidHideNotification, object: nil);
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        // unregister for keyboard notifications while not visible.
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil);
    }

    //MARK: - Configuration
    
     override func setUpNavigationBar() {
        
        self.title = "LOGO"
        
        var rightBarButtonItem: UIBarButtonItem? = nil;
        
        switch (presantationType!) {
            
        case .Notification:
            
            let doneBar: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done:");
            self.navigationItem.leftBarButtonItem = doneBar;
            
            rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "map_annotation_conf"), style: .Plain, target: self, action: "didTapRouteButton:");
            
        case .Detailes:
            rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "map_annotation_conf"), style: .Plain, target: self, action: "didTapRouteButton:");
            
        case .Confirmation:
            rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem:.Action, target: self, action: Selector("didTapShare:"));
            
        default:
            fatalError("No Such Presenation Type");
        }
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    
    private func configureUI() {
        
        confirmationButton.setTitleShadowColor(UIColor.clearColor(), forState: .Selected);
        confirmationButton.setTitleColor(UIColor.whiteColor(), forState: .Selected);
        
        if (appointment != nil) {
            
            nameLabel.text = appointment!.place.name;
            addressLabel.text = appointment!.place.formattedAddress;
            
            var strDist = appointment!.place.distance?.doubleValue.format(".3");
            addressLabel.text = addressLabel.text! + ", distance: \(strDist!) km.";
            
            if var phoneNumber = appointment!.place.internalPhoneNumber as String! {
                
                phoneLabel.text = phoneNumber;
                
            } else {
                
                phoneLabel.text = appointment!.place.formattedPhoneNumber;
            }
            
            dateLabel.text = "\(appointment!.fireDate.stringFromDateWithStringFormats([kTimeFormat, kDateFormat, kTimeFormat]))";
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
    
    //Mark: - handlers
    
    func done(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapRouteButton(sender: AnyObject) {
        
        self.performSegueWithIdentifier(kRouteToPlaceSegueIdentifier_1, sender: self);
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
//                    self.showAlertWith("Succeed", message: "Appointment Was Successfully Added.");
//                    println("save succeded");
                    
                    if let mainVC = appDelegate.window?.rootViewController as? SRRootMenuViewController {
                        
                        mainVC.rollbackToContentViewController();
                    }
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
        
        if let photoReference = appointment!.place.photoReference as String! {
            
            var urlString = "\(kGooglePlacePhotoAPIURL)maxheight=\(kGooglePhotoMaxHeight)&photoreference=\(photoReference)&key=\(kGooglePlaceAPIKey)";
            urlString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!;
            
            let photoURL = NSURL(string: urlString);
            pictureImageView.setImageWithURL(photoURL, placeholderImage: UIImage(named: "image_placeholder"));
        }
    }
    
    //MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        notesTextView.text = "";
        notesTextView.textColor = UIColor(red: 0.0 / 255.0, green: 132.0 / 255.0, blue: 216.0 / 255.0, alpha: 1.0);
        
        return true;
    }
    
    func textViewDidChange(textView: UITextView) {
        
        if (notesTextView.text.utf16Count == 0) {
            notesTextView.textColor = UIColor.lightGrayColor();
            notesTextView.text = "Leave your notes...";
            notesTextView.resignFirstResponder();
        }
    }
    
    //MARK: - notifications
    
    func keyboardDidShow(notification: NSNotification) {
        
        if let userinfo = notification.userInfo {

            var keyboardFrame: CGRect = (userinfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue();
            
            textViewTopLayoutConstraint.constant -= 80;
            textViewBottomLayoutConstraint.constant += 80;
            pictureImageTopLayoutConstraint.constant += 80;

            UIView.animateWithDuration(0.33, animations: {[weak self] () -> Void in
                
                if let strongSelf = self {
                    
                    strongSelf.view.layoutIfNeeded();
                }
            });
        }
    }
    
    func keyboardDidHide(notification: NSNotification) {
        
        if let userinfo = notification.userInfo {
            
            var keyboardFrame: CGRect = (userinfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue();
            
            textViewTopLayoutConstraint.constant = 12;
            textViewBottomLayoutConstraint.constant = 12;
            pictureImageTopLayoutConstraint.constant = 12;
            
            UIView.animateWithDuration(0.33, animations: {[weak self] () -> Void in
                
                if let strongSelf = self {
                    
                    strongSelf.view.layoutIfNeeded();
                }
            });
        }
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        
        if (segue.identifier == kRouteToPlaceSegueIdentifier_1) {
            
            if let navVC = segue.destinationViewController as? UINavigationController {
                
                if let destVC = navVC.viewControllers[0] as? SRPlaceRouteMapViewController {
                    
                    destVC.myCoordinate = appDelegate.currentLocation().coordinate;
                    destVC.targetCoordinate = CLLocationCoordinate2DMake(appointment!.place.lat.doubleValue, appointment!.place.lng.doubleValue);
                }
            }
        }
    }
}
