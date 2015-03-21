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
    
    var appointmentCD: SRCoreDataAppointment?;
    var appointmentST: SRAppointment?;
    var presentationType: SRConfirmationScreenType?;
   
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var locationIndicatorImageView: UIImageView!
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
        
        switch (presentationType!) {
            
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

        switch (presentationType!) {
            
        case .Confirmation:
            
            pictureImageView.hidden = true;
            var data = self.formDictionaryFromStructAppointment();
            self.fillUIFromDictionary(data);
            
        case .Detailes:
            
            pictureImageView.hidden = false;
            self.loadPlaceImage();
            if (appointmentCD!.completed.boolValue) {
                
                confirmationButton.hidden = true;
            } else {
                
                confirmationButton.setBackgroundImage(UIImage(named: "arrived_btn"), forState: .Normal);
            }
            calendarButton.hidden = true;
            notificationButton.hidden = true;
            
            if (notesTextView.text == "Leave your notes...") {
                notesTextView.hidden = true;
            }
            
            var data: [String: Any] = self.formDictionaryFromCoreDataAppointment();
            self.fillUIFromDictionary(data)
            
        case .Notification:
            
            pictureImageView.hidden = false;
            self.loadPlaceImage();
            confirmationButton.setBackgroundImage(UIImage(named: "arrived_btn"), forState: .Normal | .Highlighted | .Selected);
            calendarButton.hidden = true;
            notificationButton.hidden = true;
            
            var data: [String: Any] = self.formDictionaryFromCoreDataAppointment();
            self.fillUIFromDictionary(data)
            
        default:
            fatalError("No Such Type");
        }
    }
    
    private func formDictionaryFromCoreDataAppointment() -> Dictionary<String, Any> {
        
        var data: [String: Any] = [
            "name": appointmentCD!.place.name,
            "tracking": appointmentCD!.locationTrack,
            "formattedAddress": appointmentCD!.place.formattedAddress!,
            "distance": appointmentCD!.place.distance?.floatValue,
            "fireDate": appointmentCD!.fireDate
        ];
        
        if var internalPhoneNumber = appointmentCD!.place.internalPhoneNumber as String! {
            
            data["internalPhoneNumber"] = internalPhoneNumber;
            
        } else if var formattedPhoneNumber = appointmentCD!.place.internalPhoneNumber as String! {
            
            data["formattedPhoneNumber"] = formattedPhoneNumber;
        }
        
        if var website = appointmentCD!.place.website as String! {
            
            data["website"] = website;
        }
        
        return data;
    }
    
    private func formDictionaryFromStructAppointment() -> Dictionary<String, Any> {
        
        var data: [String: Any] = [
            "name": appointmentST!.place.name!,
            "tracking": NSNumber(bool: appointmentST!.locationTrack),
            "formattedAddress": appointmentST!.place.formattedAddress!,
            "distance": appointmentST!.place.distance!,
            "fireDate": NSDate(timeIntervalSince1970: appointmentST!.dateInSeconds)
        ];
        
        if var internalPhoneNumber = appointmentST!.place.internalPhoneNumber as String! {
            
            data["internalPhoneNumber"] = internalPhoneNumber;
            
        } else if var formattedPhoneNumber = appointmentST!.place.internalPhoneNumber as String! {
            
            data["formattedPhoneNumber"] = formattedPhoneNumber;
        }
        
        if var website = appointmentST!.place.website as String! {
            
            data["website"] = website;
        }
        
        return data;
    }
    
    private func fillUIFromDictionary(data: Dictionary<String, Any>) {
        
        if let locationTracking = data["tracking"] as? NSNumber {
            
            locationIndicatorImageView.image = locationTracking.boolValue ? UIImage(named: "map_annotation_sel") : UIImage(named: "map_annotation_conf");
        }
        
        nameLabel.text = data["name"] as? String;
        addressLabel.text = (data["formattedAddress"] as? String)?.capitalizedString;

        var dist = data["distance"] as? CGFloat;
        if (dist != nil) {
            
            var strDist = Double(dist!).format(".3");
            addressLabel.text = addressLabel.text! + ", distance: \(strDist) km.";
        }
        
        if var phoneNumber = data["internalPhoneNumber"] as? String {
            
            phoneLabel.text = phoneNumber;
            
        } else {
            
            phoneLabel.text = data["formattedPhoneNumber"] as? String;
        }
        
        if let fireDate = data["fireDate"] as? NSDate {
            
            dateLabel.text = "\(fireDate.stringFromDateWithStringFormats([kTimeFormat, kDateFormat, kTimeFormat]))";
        }
        websiteLabel.text = data["website"] as? String;
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
                
            self.removeAppointmentFromCalendar(byIdintifier: appointmentST!.calendarId!);
            btn.selected = false;
        }
    }
    
    @IBAction func trackLocationDidTap(sender: AnyObject) {
        
        var btn = sender as UIButton;
        btn.selected = !btn.selected;

        appointmentST!.toggleLocationTrack(btn.selected);
        locationIndicatorImageView.image = btn.selected ? UIImage(named: "map_annotation_sel") : UIImage(named: "map_annotation_conf");
    }
    
    @IBAction func finishDidTap(sender: AnyObject) {
        
        var btn = sender as UIButton;
        
        if (!btn.selected) {
            
            btn.selected = true;
            switch(presentationType!) {
                
            case .Confirmation:
                
                if (notesTextView.text.utf16Count > 0) {
                    
                    appointmentST!.description = notesTextView.text;
                }
                var result = SRCoreDataAppointment.insertAppointment(appointmentST!);
                
                switch result {
                    
                case .Success(let quotient):
                    
                    println("Debug. Added appointment!");
                    if let mainVC = appDelegate.window?.rootViewController as? SRRootMenuViewController {
                        
                        mainVC.rollbackToContentViewController();
                    }
                    
                case .Failure(let error):
                    println("Debug. Adding failed");
                    self.showAlertWith("Error", message: "\(error)");
                }
                
            case .Detailes:
                
                if (appointmentCD != nil) {
                    
                    SRCoreDataAppointment.markArrivedAppointmnetWithId(appointmentCD!.id);
                    
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
                
                switch (strongSelf.presentationType!) {
                    
                case .Confirmation:
                    
                    var event = EKEvent(eventStore: store);
                    event.title = "CitiGuide. Visit \(strongSelf.appointmentST!.place.name)";
                    event.location = strongSelf.appointmentST!.place.formattedAddress;
                    
                    if (strongSelf.appointmentST?.description != "") {
                        
                        event.notes = strongSelf.appointmentST!.description;
                    }
                    
                    event.startDate = NSDate(timeIntervalSince1970: strongSelf.appointmentST!.dateInSeconds);
                    event.endDate = event.startDate.dateByAddingTimeInterval(60.0 * 30.0); //30 minute
                    
                    let alarm: EKAlarm = EKAlarm(absoluteDate: event.startDate.dateByAddingTimeInterval(60 * (-30)));
                    
                    event.addAlarm(alarm);
                    event.calendar = store.defaultCalendarForNewEvents;
                    
                    var error: NSError?;
                    store.saveEvent(event, span: EKSpanThisEvent, commit: true, error: &error);
                    
                    if (error == nil) {
                        
                        strongSelf.appointmentST!.calendarId = event.eventIdentifier;
                        strongSelf.showAlertWith("Message", message: "Event Was Succesfully Added To Calendar!");
                    }
                    
                default:
                    println("No Calendar")
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
        
        var photoReference: String? = nil;
        
        switch(presentationType!) {
            
        case .Confirmation:
            
            if (appointmentST!.place.photoReferences?.count != 0) {
                
                photoReference = appointmentST!.place.photoReferences![0] as String!;
            }
            
        case .Detailes:
            photoReference = appointmentCD!.place.photoReference as String!;
            
        default:
            println("!!");
        }
        
        if (photoReference != nil) {
            
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
                    
                    var location: CLLocation? = nil;
                    switch (presentationType!) {
                    case .Confirmation:
                        
                        location = CLLocation(latitude: appointmentST!.place.lat, longitude: appointmentST!.place.lng);
                    
                    case .Detailes, .Notification:
                        
                        location = CLLocation(latitude: appointmentCD!.place.lat.doubleValue, longitude: appointmentCD!.place.lng.doubleValue);
                    }
                    
                    if (location != nil) {
                        
                        destVC.myCoordinate = appDelegate.currentLocation().coordinate;
                        destVC.targetCoordinate = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude);
                        
                    } else {
                        
                        fatalError("No Coordinates");
                    }
                }
            }
        }
    }
}
