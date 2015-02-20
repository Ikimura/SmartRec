//
//  SRClusteringMapVIew.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/17/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRClusteringMapView: SRBaseMapView {
    
    private var markerClusters: [SRMarkersCluster]?;
    private var oldMarkerClusters: [GMSMarker]?;
    private var oldZoom: CGFloat?;
    
    private var updateVisibleAnnotationsTimer: NSTimer?;
    private var clusterImageCache: NSMutableDictionary?;
    
    let M_PI_180: CGFloat = CGFloat(M_PI / 180);

    override func awakeFromNib() {
        super.awakeFromNib();
        
        self.clusterImageCache = NSMutableDictionary();
    }
    
    
    
    override func reloadMarkersList() {
        self.oldMarkerClusters = nil;
        
        self.removeAllMapMarkers();
        self.hideCalloutView();
        self.createDistanceBetweenMarkerMap();
        self.setNeedUpdateClusterList();
    }
    
    //MARK: - GMSMapViewDelegate (Override)
    
    override func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        super.mapView(mapView, didChangeCameraPosition: position);
        
//        if (self.oldZoom != self.googleMapView.camera.zoom) {
//            self.oldZoom = self.googleMapView.camera.zoom;
//            self.setNeedUpdateClusterList();
//        } else {
//            self.showVisibleCluster();
//        }
    }
    
    //MARK: - private
    
    private func removeAllMapMarkers() {
        
        for var i = 0; i < self.mapMarkers?.count; i++ {
            self.mapMarkers![i].map = nil;
        }
        
        self.mapMarkers = [];
    }
    
    private func createDistanceBetweenMarkerMap() {
        //FIXME: -
//        free(distanceBetweenLocationCache);

        let count: Int = self.dataSource!.numberOfMarkers();
        //FIXME: -

//        distanceBetweenLocationCache = (CGFloat **)malloc(count * sizeof(CGFloat *));

        for var i = 0; i < count; i++ {
            //FIXME: -

//            CGFloat *distanceCache = (CGFloat *)malloc(count * sizeof(CGFloat));
            let firstLocation: CLLocationCoordinate2D = self.dataSource!.locationForMarkerAtIndex(i)!;
            
            for var j = i + 1; j < count; j++ {
                let secondLocation: CLLocationCoordinate2D = self.dataSource!.locationForMarkerAtIndex(j)!;
                //FIXME: -

                let distance: CGFloat = self.distanceBetweenLocation(firstLocation, secondLocation: secondLocation);
//                distanceCache[j] = dist;

            }
//            distanceBetweenLocationCache[i] = distanceCache;
        }
    }
    
    private func distanceBetweenLocation(firstLocation: CLLocationCoordinate2D, secondLocation: CLLocationCoordinate2D) -> CGFloat {
        
        let R: CGFloat = 6371; // Radius of the Earth in km
        let dLat: CGFloat = CGFloat(secondLocation.latitude - firstLocation.latitude) * M_PI_180;
        let dLon: CGFloat = CGFloat(secondLocation.longitude - firstLocation.longitude) * M_PI_180;

        var a: CGFloat = sin(dLat / 2.0) * sin(dLat / 2.0);
        a = a + cos(CGFloat(firstLocation.latitude) * M_PI_180) * cos(CGFloat(secondLocation.latitude) * M_PI_180) * sin(dLon / 2.0) * sin(dLon / 2.0);
        
        let c: CGFloat = 2 * atan2(sqrt(a), sqrt(1 - a));
        
        let distanse: CGFloat = R * c;
        
        return distanse;
    }
    
    private func setNeedUpdateClusterList() {
        let interval: NSTimeInterval = 0.2;

        if (self.updateVisibleAnnotationsTimer == nil ) {
            self.updateVisibleAnnotationsTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "updateClusterList", userInfo: nil, repeats: false);
        } else {
            self.updateVisibleAnnotationsTimer!.fireDate = NSDate(timeIntervalSinceNow: interval);
        }
    }
    
    private func showVisibleCluster() {
        
        let projection: GMSProjection = self.googleMapView.projection;
        var mapM: [GMSMarker] = [];
        
        for var i = 0; i < self.markerClusters?.count; i++ {
            if var cluster = self.markerClusters?[i] as SRMarkersCluster! {
                var clusterLocation: CLLocationCoordinate2D = cluster.clusterLocation!;
                
                if (cluster.isShowing == false && projection.containsCoordinate(clusterLocation)) {
                    cluster.isShowing = true;
                    
                    var marker: GMSMarker? = nil;
                    
                    if (cluster.indexesForMarkers.count == 1) {
                        let index: NSInteger = cluster.indexesForMarkers[0];
                        //FIXME: -
                        //                    marker = [self dequeueOldMakerWithIndex:index];
                    } else {
                        marker = GMSMarker();
                        marker?.position = clusterLocation;
                        //FIXME: -
                        //                    marker.icon = [self clusterImageWithCount:cluster.indexesForMarkers.count];
                        marker?.groundAnchor = CGPointMake(0.5, 0.5);
                        marker?.userData = cluster;
                    }
                    
                    marker?.map = self.googleMapView;
                    mapM.append(marker!);
                }
            }
            //FIXME: -
//            self.mapMarkers!.join(mapM);
            //FIXME: -
            //        [self hideCalloutViewIfNeed];

        }
    }
    
    //MARK: - Utils
    
    private func dequeueOldMakerWithIndex(index: Int) -> GMSMarker {
        for var i = 0; i < self.oldMarkerClusters?.count; i++ {
            var oldMarker: GMSMarker = self.oldMarkerClusters![i];
            
            if let num = oldMarker.userData as? NSNumber {
                
                if num.integerValue == index {
                    
                    return oldMarker;
                }
            }
        }
        return self.makerAtIndex(index);
    }
    
}