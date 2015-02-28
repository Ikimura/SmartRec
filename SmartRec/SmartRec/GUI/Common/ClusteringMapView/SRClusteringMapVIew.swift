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
    private var oldZoom: Float?;
    
    private var updateVisibleAnnotationsTimer: NSTimer?;
    private var clusterImageCache: NSMutableDictionary?;
    
    private var distanceBetweenLocationCache: Array<Array<CGFloat>>?;
    
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
        
        if (self.oldZoom != self.googleMapView.camera.zoom ) {
            self.oldZoom = self.googleMapView.camera.zoom;
            self.setNeedUpdateClusterList();
        } else {
            self.showVisibleCluster();
        }
    }
    
    override func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        var retrunValue = true;
        
        if let cluster = marker.userData as? SRMarkersCluster {
            
            self.openCluster(cluster);
            
        } else {
            retrunValue = super.mapView(mapView, didTapMarker: marker);
        }
        
        return retrunValue;
    }
    
    //MARK: - private
    //FIXMEL: last checl
    private func createDistanceBetweenMarkerMap() {
        self.distanceBetweenLocationCache = nil;

        let count: Int = self.dataSource!.numberOfMarkers();

        self.distanceBetweenLocationCache = Array<Array<CGFloat>>();

        for var i = 0; i < count; i++ {
            
            var distanceCache = [CGFloat](count: count, repeatedValue: 0.0);

            let firstLocation: CLLocationCoordinate2D = self.dataSource!.locationForMarkerAtIndex(i)!;
            
            for var j = i + 1; j < count; j++ {
                
                let secondLocation: CLLocationCoordinate2D = self.dataSource!.locationForMarkerAtIndex(j)!
                
                let distance: CGFloat = self.distanceBetweenLocation(firstLocation, secondLocation: secondLocation);
                distanceCache[j] = distance;

            }
            self.distanceBetweenLocationCache?.append(distanceCache);
        }
    }
    
    private func setNeedUpdateClusterList() {
        let interval: NSTimeInterval = 0.2;
        
        if (self.updateVisibleAnnotationsTimer == nil) {
            self.updateVisibleAnnotationsTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "updateClusterList", userInfo: nil, repeats: false);
        } else {
            self.updateVisibleAnnotationsTimer!.fireDate = NSDate(timeIntervalSinceNow: interval);
        }
    }
    
    func updateClusterList() {
        
        self.updateVisibleAnnotationsTimer?.invalidate();
        self.updateVisibleAnnotationsTimer = nil;
        
        let loc1: CLLocationCoordinate2D = self.googleMapView.projection.coordinateForPoint(CGPointMake(0, 0));
        
        let loc2: CLLocationCoordinate2D = self.googleMapView.projection.coordinateForPoint(CGPointMake(CGRectGetMaxX(self.googleMapView.bounds), CGRectGetMaxY(self.googleMapView.bounds)));
        
        let defaultDistanceBetweenLocation: CGFloat = self.distanceBetweenLocation(loc1, secondLocation: loc2) / 10;
        
        var count = self.dataSource!.numberOfMarkers();
        
        var markerClusterers: [SRMarkersCluster] = Array<SRMarkersCluster>();
        
        for var i = 0; i < count; i++ {
            var distanceBetweenLocation = defaultDistanceBetweenLocation;
            
            var insideToCluster: SRMarkersCluster? = nil;
            
            for var j = 0; j < markerClusterers.count; j++ {
                
                if let cl = markerClusterers[j] as SRMarkersCluster! {
                    let distanse = self.distanceBetweenLocationFromCache(i, index2: cl.point!);
                    
                    if (distanse < distanceBetweenLocation) {
                        distanceBetweenLocation = distanse;
                        insideToCluster = cl;
                    }
                }
            }
            
            if (insideToCluster == nil) {
                let location: CLLocationCoordinate2D = self.dataSource!.locationForMarkerAtIndex(i)!;
                
                insideToCluster = SRMarkersCluster();
                insideToCluster!.point = i;
                insideToCluster!.clusterLocation = location;
                markerClusterers.append(insideToCluster!);
            }
            
            insideToCluster?.indexesForMarkers.append(i);
        }
        
        
        self.markerClusters = markerClusterers;
        self.oldMarkerClusters = self.mapMarkers;
        
        self.removeAllMapMarkers();
        
        self.showVisibleCluster();
    }
    
    private func showVisibleCluster() {
        
        let projection: GMSProjection = self.googleMapView.projection;
        var mapM = Array<GMSMarker>();
        
        for var i = 0; i < self.markerClusters?.count; i++ {
            
            if var cluster = self.markerClusters?[i] as SRMarkersCluster! {
                var clusterLocation: CLLocationCoordinate2D = cluster.clusterLocation!;
                
                if (!cluster.isShowing && projection.containsCoordinate(clusterLocation)) {
                    cluster.isShowing = true;
                    
                    var marker: GMSMarker? = nil;
                    
                    if (cluster.indexesForMarkers.count == 1) {
                        
                        let index: NSInteger = cluster.indexesForMarkers[0];
                        marker = self.dequeueOldMakerWithIndex(index);
                        
                    } else {
                        
                        marker = GMSMarker();
                        marker!.position = clusterLocation;
                        marker!.icon = self.clusterImageWithCount(cluster.indexesForMarkers.count);
                        marker!.groundAnchor = CGPointMake(0.5, 0.5);
                        marker!.userData = cluster;
                    }
                    
                    marker?.map = self.googleMapView;
                    mapM.append(marker!);
                }
            }
        }
        
        for var i = 0; i < mapM.count; i++ {
            self.mapMarkers?.append(mapM[i]);
        }
        self.hideCalloutViewIfNeed();
    }
    
    private func hideCalloutViewIfNeed() {
        
        if (googleMapView.selectedMarker == nil) {
            
            return;
        } else {
            
            if let data = googleMapView.selectedMarker.userData as? NSNumber {
                
                if (!contains(mapMarkers!, googleMapView.selectedMarker)) {
                    self.hideCalloutView();
                }
            }
        }
    }
    
    private func openCluster(cluster: SRMarkersCluster) {
        var coordinateBounds: GMSCoordinateBounds = GMSCoordinateBounds();
        
        for var i = 0; i < cluster.indexesForMarkers.count; i++ {
            
            let location: CLLocationCoordinate2D = self.dataSource!.locationForMarkerAtIndex(cluster.indexesForMarkers[i])!;
            
            coordinateBounds = coordinateBounds.includingCoordinate(location);
        }
        
        let mapInsets: UIEdgeInsets = UIEdgeInsetsMake(70.0, 20, 0.0, 20);
        
        let camera: GMSCameraUpdate = GMSCameraUpdate.fitBounds(coordinateBounds, withEdgeInsets: mapInsets);
        
        self.googleMapView.animateWithCameraUpdate(camera);
    }
    
    private func removeAllMapMarkers() {
        
        for var i = 0; i < mapMarkers?.count; i++ {
            mapMarkers![i].map = nil;
        }
        
        mapMarkers = [];
    }
    
    private func clusterImageWithCount(count: Int) -> UIImage {
        if let outputImage = self.clusterImageCache!["\(count)"] as? UIImage {
            return outputImage;
            
        } else {
            var inputImage = UIImage(named: "m1");
            
            var text: String = "\(count)";
            var width = inputImage?.size.width;
            var height = inputImage?.size.height;
            
            UIGraphicsBeginImageContextWithOptions(inputImage!.size, false, 0.0);
            var context:CGContextRef = UIGraphicsGetCurrentContext();
            UIGraphicsPushContext(context);
            
            inputImage?.drawInRect(CGRectMake(0, 0, width!, height!));
            UIGraphicsPopContext();
            
            let myString: NSString = text as NSString
            
            var attributes = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSFontAttributeName: UIFont(name: "Helvetica", size: 11.0)!];
            
            let textSize: CGSize = myString.sizeWithAttributes(attributes);
            
            var position: CGPoint = CGPoint(x: ceil((width! - textSize.width) / 2) - 1, y: (height! - textSize.height) / 2);
            
            myString.drawAtPoint(position, withAttributes: attributes);
            
            var outputImgae: UIImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            self.clusterImageCache?.setValue(outputImgae, forKey: "\(count)");
            
            return outputImgae;
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

    private func distanceBetweenLocationFromCache(index1: Int, index2: Int) -> CGFloat {
        if (index1 < index2) {
            return self.distanceBetweenLocationCache![index1][index2];
        } else {
            return self.distanceBetweenLocationCache![index2][index1];
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