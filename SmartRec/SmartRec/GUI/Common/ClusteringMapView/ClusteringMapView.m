////
////  ClusteringMapView.m
////  BookCiti
////
////  Created by Ruslan Maslouski on 10/14/14.
////  Copyright (c) 2014 Alexander M. All rights reserved.
////
//
//#import "ClusteringMapView.h"
//#import "ClusterOfMarkers.h"
//
//@interface ClusteringMapView () {
//    CGFloat **distanceBetweenLocationCache;
//}
//
//@property (nonatomic, strong) NSArray *markerClusterers;
//@property (nonatomic, strong) NSArray *oldMrkerClusterers;
//@property (nonatomic, assign) CGFloat oldZoom;
//
//@property (nonatomic, assign) NSTimer *updateVisibleAnnotationsTimer;
//@property (nonatomic, strong) NSMutableDictionary *clusterImageCache;
//
//@end
//
//@implementation ClusteringMapView
//
//- (void)awakeFromNib {
//    [super awakeFromNib];
//    self.clusterImageCache = [NSMutableDictionary dictionary];
//}
//
//- (void)dealloc {
//    free(distanceBetweenLocationCache);
//}
//
//- (void)reloadMarkersList {
//    self.oldMrkerClusterers = nil;
//    [self removeAllMapMarkers];
//    [self hideCalloutView];
//    [self createDistanceBetweenMarkerMap];
//    [self setNeedUpdateClusterList];
//}
//
//#pragma mark - GMSMapViewDelegate (Override)
//
//- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
//    [super mapView:mapView didChangeCameraPosition:position];
//    
//    if (self.oldZoom != self.mapView.camera.zoom) {
//        self.oldZoom = self.mapView.camera.zoom;
//        [self setNeedUpdateClusterList];
//    } else {
//        [self showVisibleCluster];
//    }
//}
//
//- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
//    BOOL returnValue = YES;
//    if ([marker.userData isKindOfClass:[ClusterOfMarkers class]]) {
//        [self openCluster:marker.userData];
//    } else {
//        returnValue = [super mapView:mapView didTapMarker:marker];
//    }
//    
//    return returnValue;
//}
//
//#pragma mark - Private
//
//- (void)createDistanceBetweenMarkerMap {
//    NSLog(@"Create distance map");
//    free(distanceBetweenLocationCache);
//    NSInteger count = [self.dataSource numberOfMarkers];
//    distanceBetweenLocationCache = (CGFloat **)malloc(count * sizeof(CGFloat *));
//    for (int i = 0; i < count; i++) {
//        CGFloat *distanceCache = (CGFloat *)malloc(count * sizeof(CGFloat));
//        CLLocationCoordinate2D location1 = [self.dataSource locationForMarkerAtIndex:i];
//        for (int j = i+1; j < count; j++) {
//            CLLocationCoordinate2D location2 = [self.dataSource locationForMarkerAtIndex:j];
//            CGFloat dist = [self distanceBetweenLocation:location1 location2:location2];
//            distanceCache[j] = dist;
//        }
//        distanceBetweenLocationCache[i] = distanceCache;
//    }
//    NSLog(@"End create distance map");
//}
//
//- (void)setNeedUpdateClusterList {
//    NSTimeInterval interval = 0.2;
//    if (!self.updateVisibleAnnotationsTimer) {
//        self.updateVisibleAnnotationsTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateClusterList) userInfo:nil repeats:NO];
//    } else {
//        [self.updateVisibleAnnotationsTimer setFireDate:[[NSDate date] dateByAddingTimeInterval:interval]];
//    }
//}
//
//- (void)updateClusterList {
//    [self.updateVisibleAnnotationsTimer invalidate];
//    self.updateVisibleAnnotationsTimer = nil;
//    
//    CLLocationCoordinate2D loc1 = [self.mapView.projection coordinateForPoint:CGPointMake(0, 0)];
//    CLLocationCoordinate2D loc2 = [self.mapView.projection coordinateForPoint:CGPointMake(CGRectGetMaxX(self.mapView.bounds), CGRectGetMaxY(self.mapView.bounds))];
//    
//    CGFloat defaultDistanceBetweenLocation = [self distanceBetweenLocation:loc1 location2:loc2] / 10;
//    NSLog(@"start with zoom:%f defaultDistance: %f", self.mapView.camera.zoom, defaultDistanceBetweenLocation);
//    
//    NSMutableArray *markerClusterers = [NSMutableArray array];
//    NSInteger count = [self.dataSource numberOfMarkers];
//    for (int i = 0; i < count; i++) {
//        CGFloat distanceBetweenLocation = defaultDistanceBetweenLocation;
//        ClusterOfMarkers *insideToCluster = nil;
//        for (ClusterOfMarkers *cluster in markerClusterers) {
//            CGFloat distance = [self distanceBetweenLocationFromCacheWithIndex1:i index2:cluster.point];
//            if (distance < distanceBetweenLocation) {
//                distanceBetweenLocation = distance;
//                insideToCluster = cluster;
//            }
//        }
//        if (!insideToCluster) {
//            CLLocationCoordinate2D location = [self.dataSource locationForMarkerAtIndex:i];
//            insideToCluster = [ClusterOfMarkers new];
//            insideToCluster.point = i;
//            insideToCluster.clusterLocation = location;
//            [markerClusterers addObject:insideToCluster];
//        }
//        NSValue *point = @(i);
//        [insideToCluster.indexesForMarkers addObject:point];
//    }
//    self.markerClusterers = [NSArray arrayWithArray:markerClusterers];
//    
//    self.oldMrkerClusterers = self.mapMarkers;
//    [self removeAllMapMarkers];
//    
//    [self showVisibleCluster];
//    NSLog(@"stop");
//}
//
//- (void)showVisibleCluster {
//    GMSProjection *projection = self.mapView.projection;
//    NSMutableArray *mapMarkers = [NSMutableArray array];
//    for (ClusterOfMarkers *cluster in self.markerClusterers) {
//        CLLocationCoordinate2D clusterLocation = [cluster clusterLocation];
//        if (!cluster.isShow && [projection containsCoordinate:clusterLocation]) {
//            cluster.isShow = YES;
//            
//            GMSMarker *marker;
//            if (cluster.indexesForMarkers.count == 1) {
//                NSInteger index = [cluster.indexesForMarkers[0] integerValue];
//                marker = [self dequeueOldMakerWithIndex:index];
//            } else {
//                marker = [[GMSMarker alloc] init];
//                marker.position = clusterLocation;
//                marker.icon = [self clusterImageWithCount:cluster.indexesForMarkers.count];
//                marker.groundAnchor = CGPointMake(0.5f, 0.5f);
//                marker.userData = cluster;
//            }
//            marker.map = self.mapView;
//            [mapMarkers addObject:marker];
//        }
//    }
//    self.mapMarkers = [self.mapMarkers arrayByAddingObjectsFromArray:mapMarkers];
//    
//    [self hideCalloutViewIfNeed];
////    NSLog(@"added markers: %d", mapMarkers.count);
//}
//
//- (void)hideCalloutViewIfNeed {
//    if (!self.mapView.selectedMarker) {
//        return;
//    }
//    if ([self.mapView.selectedMarker.userData isKindOfClass:[NSNumber class]] && ![self.mapMarkers containsObject:self.mapView.selectedMarker]) {
//        [self hideCalloutView];
//    }
//}
//
//- (void)openCluster:(ClusterOfMarkers *)cluster {
//    GMSCoordinateBounds *coordinateBounds = [[GMSCoordinateBounds alloc] init];
//    for (NSNumber *marker in cluster.indexesForMarkers) {
//        CLLocationCoordinate2D location = [self.dataSource locationForMarkerAtIndex:[marker integerValue]];
//        coordinateBounds = [coordinateBounds includingCoordinate:location];
//    }
//    UIEdgeInsets mapInsets = UIEdgeInsetsMake(70.0, 20, 0.0, 20);
//    GMSCameraUpdate *camera = [GMSCameraUpdate fitBounds:coordinateBounds withEdgeInsets:mapInsets];
//    [self.mapView animateWithCameraUpdate:camera];
//}
//
//- (void)removeAllMapMarkers {
//    for (GMSMarker *marker in self.mapMarkers) {
//        marker.map = nil;
//    }
//    self.mapMarkers = [NSArray array];
//}
//
//#pragma mark - Utils
//
//- (UIImage *)clusterImageWithCount:(NSInteger)count {
//    UIImage *outputImage = [self.clusterImageCache objectForKey:@(count)];
//    if (!outputImage) {
//        UIImage *inputImage = [UIImage imageNamed:@"m1"];
//        
//        NSString *text = [NSString stringWithFormat:@"%ld", (long)count];
//        CGFloat width = inputImage.size.width;
//        CGFloat height = inputImage.size.height;
//        
//        UIGraphicsBeginImageContextWithOptions(inputImage.size, NO, 0.0);
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        
//        UIGraphicsPushContext(context);
//        [inputImage drawInRect:CGRectMake(0, 0, width, height)];
//        UIGraphicsPopContext();
//        
//        UIFont* font = [UIFont fontWithName:@"Helvetica" size:11.0];
//        NSDictionary *attributes = @{NSFontAttributeName : font,
//                                     NSForegroundColorAttributeName : [UIColor whiteColor]};
//        
//        CGSize textSize = [text sizeWithAttributes:attributes];
//        CGPoint position;
//        position.x = ceil((width - textSize.width) / 2)-1;
//        position.y = (height - textSize.height) / 2;
//        
//        [text drawAtPoint:position withAttributes:attributes];
//        
//        outputImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        [self.clusterImageCache setObject:outputImage forKey:@(count)];
//    }
//    
//    return outputImage;
//}
//
//- (CGFloat)distanceBetweenLocation:(CLLocationCoordinate2D)location1 location2:(CLLocationCoordinate2D)location2 {
//    static CGFloat M_PI_180 = M_PI / 180;
//    
//    CGFloat d;
//    CGFloat R = 6371; // Radius of the Earth in km
//    CGFloat dLat = (location2.latitude - location1.latitude) * M_PI_180;
//    CGFloat dLon = (location2.longitude - location1.longitude) * M_PI_180;
//    CGFloat a = sin(dLat / 2) * sin(dLat / 2) +
//    cos(location1.latitude * M_PI_180) * cos(location2.latitude * M_PI_180) *
//    sin(dLon / 2) * sin(dLon / 2);
//    CGFloat c = 2 * atan2(sqrt(a), sqrt(1 - a));
//    d = R * c;
//    
//    return d;
//}
//
//- (CGFloat)distanceBetweenLocationFromCacheWithIndex1:(NSInteger)index1 index2:(NSInteger)index2 {
//    if (index1 < index2) {
//        return distanceBetweenLocationCache[index1][index2];
//    } else {
//        return distanceBetweenLocationCache[index2][index1];
//    }
//}
//
//#pragma mark - Utils
//
//- (GMSMarker *)dequeueOldMakerWithIndex:(NSInteger)index {
//    for (GMSMarker *oldMarker in self.oldMrkerClusterers) {
//        NSNumber *num = (id)oldMarker.userData;
//        if ([num isKindOfClass:[NSNumber class]] && [num integerValue] == index) {
//            return oldMarker;
//        }
//    }
//    return [self makerAtIndex:index];
//}
//
//@end
