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
    
    private var placeToDetaile: SRCoreDataPlace?;
    private lazy var googleServicesProvider: SRGoogleServicesDataProvider = {
        var tempProvider = SRGoogleServicesDataProvider();
        return tempProvider;
    }();
    private let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate;

    convenience init(placeToDetaile: SRCoreDataPlace) {
        self.init();
        
        self.placeToDetaile = placeToDetaile;
    }
    
    //MARK: - public interface
    
    func loadData(complitionBlock:() -> Void, errorBlock:(error: NSError?) -> Void) {
    
        if (placeToDetaile!.fullData) {
            
            complitionBlock();
            
        } else {
            
            SRPlacesController.sharedInstance.placeDetails(placeToDetaile!.reference, complitionBlock: { [weak self] (data, error) -> Void in
                
                if (data != nil) {
                    
                    complitionBlock();
                    
                } else {
                    
                    errorBlock(error: error);
                }
            });
        }
    }
    
    func numberOfSections() -> Int {
        var sections = 1;
        
        if (placeToDetaile != nil) {
            
            sections++;
        }
        
        if (placeToDetaile?.photoReference != nil) {
            
            sections++;
        }
        
        return sections;
    }
    
    func numberItemsInSection(index: Int) -> Int {
        
        var items = 0;
        
        switch (index) {
        case 0:
            items = 1;
            if (placeToDetaile!.weekdayText != nil) {
                items++;
            }
        case 1: items = 1;
        case 2:
            if (placeToDetaile!.photoReference != nil) {
                items++;
            }
            
        default:
            fatalError("Wrong Section Index");
        }
        
        return items;
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> Any {
        
        switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                
                return placeToDetaile!;
            } else {
                return placeToDetaile!.weekdayText!;
            }

        case 2: return placeToDetaile!.photoReference!
            
        default:
            fatalError("Wrong section number");
        }
    }
}