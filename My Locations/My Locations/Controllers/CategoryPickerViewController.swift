//
//  CategoryPickerViewController.swift
//  My Locations
//
//  Created by Abel Osorio on 2/17/16.
//  Copyright © 2016 Abel Osorio. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
    
    var selectedCategoryName = ""
    var selectedIndexPath = NSIndexPath()
    
    let categories = [ "No Category", "Apple Store", "Bar", "Bookstore", "Club","Grocery Store", "Historic Building", "House","Icecream Vendor", "Landmark","Park"]
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSelectedCategory()
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .White
    }
    
    func updateSelectedCategory(){
        
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
            selectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
            break
            }
        }
    }
    
    
    //MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
            return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName{
        cell.accessoryType = .Checkmark
    }else{
        cell.accessoryType = .None
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            
            if indexPath.row != selectedIndexPath.row {
            
            if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
        newCell.accessoryType = .Checkmark
            }
            if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
        oldCell.accessoryType = .None
            }
            
            selectedIndexPath = indexPath
            }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.blackColor()
        if let textLabel = cell.textLabel {
            textLabel.textColor = UIColor.whiteColor()
            textLabel.highlightedTextColor = textLabel.textColor
        }
        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        cell.selectedBackgroundView = selectionView
    }
    
    // MARK: - Navegation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickedCategory" {
        let cell = sender as! UITableViewCell
                
            if let indexPath = tableView.indexPathForCell(cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
    
}
