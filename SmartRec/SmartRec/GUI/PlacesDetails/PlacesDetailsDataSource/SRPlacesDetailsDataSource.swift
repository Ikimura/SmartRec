//
//  SRPlacesDetailsDataSource.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 3/7/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

protocol SRPlacesDetailsDataSourceProtocol {
    
    func loadData(complitionBlock:() -> Void, errorBlock:(error: NSError?) -> Void);
    func numberOfSections() -> Int;
    func numberItemsInSection(index: Int) -> Int;
    func itemAtIndexPath(indexPath: NSIndexPath) -> Any;
}

class SRPlacesDetailsDataSource : SRPlacesDetailsDataSourceProtocol {
    
    private var placeToDetaile: SRGooglePlace?;
    private lazy var googleServicesProvider: SRGoogleServicesDataProvider = {
        var tempProvider = SRGoogleServicesDataProvider();
        return tempProvider;
    }();
    private let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;

    convenience init(placeToDetaile: SRGooglePlace) {
        self.init();
        
        self.placeToDetaile = placeToDetaile;
    }
    
    //MARK: - public interface
    
    func loadData(complitionBlock:() -> Void, errorBlock:(error: NSError?) -> Void) {
    
        googleServicesProvider.placeDetails(placeToDetaile!.reference, complitionBlock: { [weak self] (data) -> Void in
            
            if var strongSelf = self {
                
                strongSelf.placeToDetaile!.fillDetailsPropertiesForPlace(data!);
                strongSelf.placeToDetaile!.addDistance(CLLocation.distanceBetweenLocation(CLLocationCoordinate2DMake(strongSelf.placeToDetaile!.lat, strongSelf.placeToDetaile!.lng), secondLocation: strongSelf.appDelegate.currentLocation().coordinate));
                
                complitionBlock();
            }
            
        }) { (error) -> Void in
            
            errorBlock(error: error);
            println(error);
        }
    }
    
    func numberOfSections() -> Int {
        var sections = 1;
        
        if (placeToDetaile != nil) {
            
            sections++;
        }
        
        if (placeToDetaile?.photoReferences?.count != 0) {
            
            sections++;
        }
        
        return sections;
    }
    
    func numberItemsInSection(index: Int) -> Int {
        
        var items = 0;
        
        switch (index) {
        case 0, 1: items = 1;
        case 2: items = placeToDetaile!.photoReferences!.count;
        default:
            fatalError("Wrong Section Index");
        }
        
        return items;
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> Any {
        
        switch (indexPath.section) {
        case 0: return placeToDetaile!;
        case 2: return placeToDetaile!.photoReferences![indexPath.row];
        default:
            fatalError("Wrong section number");
        }
    }
}