//
//  SR.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 2/25/15.
//  Copyright (c) 2015 con.epam.evnt. All rights reserved.
//

import Foundation

class SRPlacesTypesTableViewController: SRCommonViewController, UITableViewDelegate, UITableViewDataSource {

    private var typesDataSource: SRPlacseTypesDataSource?;
    private var selectedTypes:[(name: String, value: String)]?;
    
    //MARK: - Life cycle
    
    required override init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        selectedTypes = [];
        typesDataSource = SRPlacseTypesDataSource();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return typesDataSource!.numberOfTypesInSection(section);
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : SRPlacesTypesTableViewCell? = tableView.dequeueReusableCellWithIdentifier(kTupesListCellIdentifier) as? SRPlacesTypesTableViewCell;
            
        if (cell == nil) {
            
            cell = SRPlacesTypesTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: kTupesListCellIdentifier);
        }
        var tuple: (String, String) = typesDataSource!.typeAtIndex(indexPath.row)!;

        cell!.titleLabel.text = tuple.0;
        
        return cell!;
    }
    
    //MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var tuple: (name: String, value: String) = typesDataSource!.typeAtIndex(indexPath.row)!;
        
        selectedTypes? += [(name: tuple.0, value: tuple.1)];
    }

    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var tuple: (name: String, value: String) = typesDataSource!.typeAtIndex(indexPath.row)!;
        
        selectedTypes = selectedTypes?.filter{ !($0.name == tuple.name && $0.value == tuple.value) };
    }
    
    //MARK: - Handler
    
    @IBAction func continueButtonTouchUpInside(sender: AnyObject) {
        self.performSegueWithIdentifier(kShowPlaceOnMapSegueIdentifier, sender: self);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == kShowPlaceOnMapSegueIdentifier {
            
            if let viewController:SRPlacesMapViewController = segue.destinationViewController as? SRPlacesMapViewController {
                
                viewController.placesTypes = selectedTypes;
            }            
        }
    }
}
