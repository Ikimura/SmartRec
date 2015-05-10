//
//  SRPlacesController.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/25/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation
import CoreData

class SRPlacesController {
    
    class var sharedInstance: SRPlacesController {
        struct Static {
            static let instance: SRPlacesController = SRPlacesController();
        }
        return Static.instance;
    }
    
    private lazy var googleServicesProvider: SRGoogleServicesDataProvider = {
        var tempProvider = SRGoogleServicesDataProvider();
        return tempProvider;
    }();
    
    private lazy var serialQueue: dispatch_queue_t = {
        
        return dispatch_queue_create("com.placeSerrializeData.serialQueue", DISPATCH_QUEUE_SERIAL);
    }();
    
    func nearbyPlaces(coordinate: CLLocationCoordinate2D, radius: Int, types: [String], keyword: String?, name: String?, complitionBlock: (placesId: [String]?, error: NSError?) -> Void) {

        googleServicesProvider.nearbySearchPlaces(coordinate.latitude, lng: coordinate.longitude, radius: radius, types: types, keyword: keyword, name: name, complitionBlock: { [weak self] (data) -> Void in
            
            if var strongSelf = self {
                
                strongSelf.serrializePlacesFromResponseDictionary(data, complitionBlock: { (placesIds ,error) -> Void in
                    
                    complitionBlock(placesId: placesIds, error: error);
                    println("Caching has Finished.")
                });
            }
            
        }) { (error) -> Void in
            
            complitionBlock(placesId: nil, error: error);
        }
    }
    
    func textSearchPlace(textQeury: String, coordinate: CLLocationCoordinate2D?, radius: Int?, types:[String]?, complitionBlock: (placesId: [String]?, error: NSError?) -> Void) {
        
        googleServicesProvider.placeTextSearch(textQeury, lat: coordinate?.latitude, lng: coordinate?.longitude, radius: radius, types: types, complitionBlock: { [weak self] (data) -> Void in
            
            if let strongSelf = self {
                
                strongSelf.serrializePlacesFromResponseDictionary(data, complitionBlock: { (placesIds, error) -> Void in

                    complitionBlock(placesId: placesIds, error: error);
                });
            }
            
        }) { (error) -> Void in
            
            complitionBlock(placesId: nil, error: error);
        }
    }

    func placeDetails(placeReference: String, complitionBlock: (place: SRCoreDataPlace?, error: NSError?) -> Void) {
        
        googleServicesProvider.placeDetails(placeReference, complitionBlock: { [weak self] (data) -> Void in
            
            if var strongSelf = self {
                
                if (data != nil) {
                    
                    dispatch_async(strongSelf.serialQueue, { () -> Void in
                        
                        var workingContext = SRCoreDataContextProvider.workingManagedObjectContext();
                        var existPlaceEntity: SRCoreDataPlace? = SRCoreDataManager.sharedInstance.findOrCreateManagedObject(kManagedObjectPlace, predicate: NSPredicate (format: "reference == %@", placeReference)!, inContext: workingContext) as? SRCoreDataPlace;
                        
                        existPlaceEntity?.fillPropertiesFromDetailsDectionary(data!);
                        existPlaceEntity?.fullData = true;
                        
                        //Save context
                        SRCoreDataContextProvider.saveWorkingContext(workingContext);
                        //Call complition
                        complitionBlock(place: existPlaceEntity, error: nil);
                    });
                }
            }
            
            }) { (error) -> Void in
                
                println(error);
                complitionBlock(place: nil, error: error);
        }
    }
    
    func cashedPlacesWith(types: [String], textSearch: String?, andLocationCordinate: CLLocationCoordinate2D, inRadius: Int, complitionBlock:(placesId: [String]?, error: NSError?) -> Void) {
        
        dispatch_async(self.serialQueue, { [weak self]() -> Void in

            if let strongSelf = self {
                var cdPlaces: [String] = [];

                var fetchRequest = NSFetchRequest(entityName: kManagedObjectPlace);
                
                var predArray : Array<NSPredicate> = []
                for type in types {
                    
                    predArray.append(NSPredicate(format: "types CONTAINS[c] %@", type)!);
                }

                if (textSearch != nil) {
                    
                    var orPredicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: predArray);
                    var searchPredicate = NSPredicate(format: "name CONTAINS[c] %@", textSearch!)!;

                    fetchRequest.predicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: [orPredicate, searchPredicate]);
                    
                } else {
                    
                    fetchRequest.predicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: predArray);
                }
                
                var workinContext = SRCoreDataContextProvider.workingManagedObjectContext();
                
                var error: NSError? = nil;
                var cashedPlaces = workinContext.executeFetchRequest(fetchRequest, error: &error);
                println("DEBUG. all Places = \(cashedPlaces?.count)");
                
                var region: CLCircularRegion = CLCircularRegion(center: andLocationCordinate, radius: Double(inRadius), identifier: "");
                
                if (error == nil) {
                    //filter places in raduis
                    cashedPlaces = cashedPlaces?.filter({ (obj: AnyObject) -> Bool in
                        
                        var place = obj as? SRCoreDataPlace;
                        var placeCoordinate = CLLocationCoordinate2DMake(place!.lat, place!.lng);
                        var contains = region.containsCoordinate(placeCoordinate);
                        if (contains) {
                            
                            cdPlaces.append(place!.placeId);
                        }
                        return contains;
                    });
                }
                
                println("DEBUG. cashedPlaces = \(cashedPlaces?.count)");
                
                if (cashedPlaces != nil) {
                    
                    complitionBlock(placesId: cdPlaces, error: nil);
                    
                } else {
                    
                    complitionBlock(placesId: cdPlaces, error: nil);
                }
            }
        });
    }
    
    private func serrializePlacesFromResponseDictionary(response: Array<NSDictionary>, complitionBlock: (places: [String], error: NSError?) -> Void) {
        
        dispatch_async(self.serialQueue, { [weak self]() -> Void in
            
            if let strongSelf = self {
                
                var workingContext = SRCoreDataContextProvider.workingManagedObjectContext();
                var cdPlaces: [String] = [];
                
                if (response.count == 0) {
                    
                    complitionBlock(places: cdPlaces, error: nil);
                }
                
                for result in response {
                    
                    var placeId = result["place_id"] as? NSString!;
                    cdPlaces.append(placeId!);

                    var existPlaceEntity: SRCoreDataPlace? = SRCoreDataManager.sharedInstance.singleManagedObject(kManagedObjectPlace, withUniqueField: placeId!, inContext: workingContext) as? SRCoreDataPlace;
                    
                    var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;
                    
                    if (existPlaceEntity == nil) {
                        
                        var placeEntity = NSEntityDescription.insertNewObjectForEntityForName(kManagedObjectPlace, inManagedObjectContext: workingContext) as? SRCoreDataPlace;
                        
                        placeEntity!.fillPropertiesFromDectionary(result);
                        println("Added place_id=\(placeId!)");
                        
                        //cound distance
                        if (placeEntity?.distance == 0) {
                            
                            placeEntity?.distance = Float(CLLocation.distanceBetweenLocation(CLLocationCoordinate2DMake(placeEntity!.lat, placeEntity!.lng), secondLocation: appDelegate.currentLocation().coordinate));
                        }
                        
                    } else {
                        
                        println("Updated place_id=\(placeId!)");
                        existPlaceEntity!.fillPropertiesFromDectionary(result);
                        
                        //cound distance
                        if (existPlaceEntity?.distance == 0) {
                            
                            existPlaceEntity?.distance = Float(CLLocation.distanceBetweenLocation(CLLocationCoordinate2DMake(existPlaceEntity!.lat, existPlaceEntity!.lng), secondLocation: appDelegate.currentLocation().coordinate));
                        }
                    }
                }
                
                if (SRCoreDataContextProvider.saveWorkingContext(workingContext)) {
                    
                    complitionBlock(places: cdPlaces, error: nil);
                }
            }
        });
    }
}