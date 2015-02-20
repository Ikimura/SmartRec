//
//  SRBaceMapView.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/14/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRBaseMapView : UIView, SRBaseMapViewProtocol, GMSMapViewDelegate, SRCalloutViewDelegate {
    
    private let verticalOffsetForCallout: CGFloat = 39;
    private lazy var calloutView: SRCalloutView! = {
        if let infoView = UIView.viewFromNibName("SRCalloutView") as? SRCalloutView!  {
            return infoView;
        } else {
            return nil;
        }
    }();
    private var emptyCalloutView: UIView?

    var dataSource: SRBaseMapViewDataSource?;
    var delegate: SRBaseMapViewDelegate?;
    var mapMarkers: [GMSMarker]?;
    
    @IBOutlet var googleMapView: GMSMapView!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        self.emptyCalloutView = UIView(frame: CGRectZero);

        self.seteUpMapView();
    }
    
    func seteUpMapView() {
        
        var coordinate: CLLocationCoordinate2D? = dataSource?.initialLocation();
        
        googleMapView.camera = GMSCameraPosition(target: coordinate!, zoom: 15, bearing: 0, viewingAngle: 0);
        
        googleMapView.delegate = self;
        googleMapView.mapType = kGMSTypeNormal;
        googleMapView.myLocationEnabled = true
        googleMapView.settings.rotateGestures = false;
    }
    
    
    //MARK: - private
    
    func accessoryForMarker(marker: GMSMarker) -> Bool {
        return true;
    }
    
    func accessoryImageForMarker(marker: GMSMarker) -> UIImage {
        return UIImage(named: "SRAccessoryImage.png")!;
    }

    //MARK: GMSMapViewDelegate
    
    func makerAtIndex(index: Int) -> GMSMarker {
        
        var marker: GMSMarker = GMSMarker();
        if var icon: UIImage = dataSource?.iconForMarkerAtIndex(index) as UIImage! {
            marker.icon = icon;
        }
        
        if var identifier: AnyObject = dataSource?.identifierForMarkerAtIndex(index) as AnyObject! {
            marker.userData = identifier;
        }
        
        marker.title = dataSource?.titleForMarkerAtIndex(index);
        marker.position = dataSource!.locationForMarkerAtIndex(index)!;
        
        return marker;
    }
    
    //MARK: - SRCalloutViewDelegate
    
    func calloutViewAccessoryControlTapped(view: SRCalloutView, control: UIControl) {
        
        delegate?.calloutAccessoryControlTappedByIdentifier(googleMapView.selectedMarker.userData);
    }
    
    //MARK: SRBaseMapViewProtocol

    //FIXME: - CHeck
    func reloadMarkersList() {
        self.hideCalloutView();
        
        var markers = self.mapMarkers;
        
        var temp: [GMSMarker] = [];
        
        var predicateTemplate: NSPredicate = NSPredicate(format: "self.userData like $identifier")!;
        var count = dataSource?.numberOfMarkers();
        
        for var i = 0; i < count; i++ {
            
            var identifier = "none";
            if var id: String = dataSource?.identifierForMarkerAtIndex(i) as? String {
                identifier = id;
            }
                        
            var marker: GMSMarker? = markers!.filter({ (m: GMSMarker!) -> Bool in
                return m.userData as String == identifier;
            }).first;
            
            if marker == nil {
                marker = self.makerAtIndex(i);
                marker!.map = googleMapView;
            }
            
            if var icon = dataSource?.iconForMarkerAtIndex(i) as UIImage! {
                marker?.icon = icon;
            }
            
            marker!.position = dataSource!.locationForMarkerAtIndex(i)!;
            
            temp.append(marker!);
        }
        
        for marker in markers! {
            if (contains(temp, marker)) {
                marker.map = nil;
            }
        }
        
        if (contains(temp, googleMapView.selectedMarker)) {
            self.hideCalloutView();
        }
        
        self.updateCalloutViewPosition(true);
        
        self.mapMarkers = temp;
    }
    
    func setupMapIfNeed() {
        if (googleMapView == nil) {
            self.seteUpMapView();
        }
    }
    
    func clearMap() {
        googleMapView = nil;
    }
    
    func setCameraCoordinate(coordinate: CLLocationCoordinate2D) {
        var camera: GMSCameraUpdate = GMSCameraUpdate.setTarget(coordinate, zoom: 8);
        googleMapView.animateWithCameraUpdate(camera);

    }
    
    //MARK: - GMSMapViewDelegate

    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView! {
        var point: CGPoint = self.calloutViewPositionWithMarker(marker);
        
        self.calloutView.textLabel.text = marker.title;
        self.calloutView.showCalloutWithPosition(point);
        
        var visibleAccessory: Bool = self.accessoryForMarker(marker);
        self.calloutView.setAccessory(visibleAccessory);
        
        if (visibleAccessory == true) {
            if var accessoryImage = self.accessoryImageForMarker(marker) as UIImage! {
                self.calloutView.accessoryButton.setImage(accessoryImage, forState: .Normal);
            }
        }
        
        return self.emptyCalloutView;
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        if (mapView.selectedMarker != nil /*&& self.calloutView.hidden != true*/) {
            self.updateCalloutViewPosition(false);
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.hideCalloutView();
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        return delegate!.didTapMarker();
    }
    
    //MARK: - CalloutView
    
    func hideCalloutView() {
        googleMapView.selectedMarker = nil;
        self.hideCalloutView();
    }
    
    func updateCalloutViewPosition(animated: Bool) {
        if (googleMapView.selectedMarker != nil) {
            var point: CGPoint = self.calloutViewPositionWithMarker(googleMapView.selectedMarker);
            self.calloutView.setPosition(point, animated: animated);
        }
    }
    
    func calloutViewPositionWithMarker(marker: GMSMarker) -> CGPoint{
        let anchor: CLLocationCoordinate2D = marker.position;
        var point = googleMapView.projection.pointForCoordinate(anchor);

        var offset = verticalOffsetForCallout;
        
        offset = dataSource!.verticalOffsetForCalloutView();
        
        point.y -= offset;
        
        return point;
    }
}
