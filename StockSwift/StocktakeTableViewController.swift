//
//  StocktakeTableViewController.swift
//  StockSwift
//
//  Created by andre trosky on 27/12/2015.
//  Copyright © 2015 andre trosky. All rights reserved.
//

import UIKit
import CoreData

//this is the class extension which makes StocktakeTableViewController conform
//to UISearchResultsUpdating.
//updateSearchResultsForSearchController is the only method that the class MUST
//implement to conform to the protocol
//whenever the user adds/removes text in the search bar, the UISearchController will
//inform StocktakeTableViewController class of the change via this method.
//the custom logic of how to handle the filtering of search is done using 
//the filterContentForSearchText func.
extension StocktakeTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        //get the search bar
        let searchBar = searchController.searchBar
        
        //get the search bar scope value selected. scope buttons are the catogories
        //of stock
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        
        //finally, call the custom func to filter search results and update UI
        filterContentForSearchText(searchController.searchBar.text!, scope:scope)
    }
}


extension StocktakeTableViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}






class StocktakeTableViewController: UITableViewController{

    // MARK: Properties
    //var stockItems = [StockItem]()
    var stockItems: [StockItem]?
    var filteredStockItems = [StockItem]()
    
    
    //playing around
    var stocktake: Stocktake?
    //var stocktakeMetaData = [String:String]()
    
    //putting nil for searchResultsController tells the app that you want to use the same view your searching in to also display the results.
    //let searchController = UISearchController(searchResultsController: nil)
    let searchController = CustomSearchController(searchResultsController: nil)
    
    
    
    
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        navigationItem.title = "Stocktake"
        
        //searchResultsUpdater is a property that conforms to the new protocol, UISearchResultsUpdating.
        //this class is assigned to it as we add the protocol methods using a class extension defined up top of file.
        searchController.searchResultsUpdater = self
        
        //dim view it is presented over which is the tableview. we don't want it dimmed
        searchController.dimsBackgroundDuringPresentation = false
        
        //make sure sesarch bar does not remain on screen if user navigates to another view controller
        //whilst the UISearchController is active
        definesPresentationContext = true
        
        //interface builder is not yet compatible with UISearchController so we add it programmatically.
        tableView.tableHeaderView = searchController.searchBar
        
        
        searchController.searchBar.scopeButtonTitles = ["ALL", "MEAT", "GROCERY", "PRODUCE", "OTHER"]
        searchController.searchBar.delegate = self
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func filterContentForSearchText(searchText: String, scope: String = "ALL") {
        //print("filterContentForSearchText and searchText: " + searchText)
        
        //this filters stockItems array based on the searchText string and 
        //will put the results into filteredStockItems array.
        //filter() takes a closure of type (item:StockItem) -> Bool
        //then it loops over all elements of the array, calls the closure passing in the current element,
        //if true is returned for that element it is added to filteredStockItems
        filteredStockItems = stockItems!.filter { item in
            
            if searchText == "" && scope != "ALL" {
                //print("filterContentForSearchText, searchText == \"\" && scope != ALL is true")
                return item.section == scope
            }
            else if searchText == "" && scope == "ALL" {
                //want all of the items
                return true
            }
            else if searchText != "" && scope == "ALL" {
                return item.description.lowercaseString.containsString(searchText.lowercaseString)
            }
            else {
                //print("filterContentForSearchText, searchText != \"\" is true")
                return (item.section == scope) && item.description.lowercaseString.containsString(searchText.lowercaseString)
            }
        }
        
        tableView.reloadData()
    }
    


    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        //find out how many rows to display factoring into account what is happening to the search bar content
        if searchController.active {
            let searchBar = searchController.searchBar
            let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
            
            if searchBar.text == "" && scope != "ALL" {
                return filteredStockItems.count
            }
            else if searchBar.text == "" && scope == "ALL" {
                return stockItems!.count
            }
            else if searchBar.text != "" && scope == "ALL" {
                return filteredStockItems.count
            }
            else {
                //searchBar.text != "" && scope != "ALL" is true
                return filteredStockItems.count
            }
        }
        else {
            return stockItems!.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "StockItemTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! StockItemTableViewCell
        
        let stockItem: StockItem
        
        //find out the state of the search terms to decide which cell it is
        if searchController.active {
            let searchBar = searchController.searchBar
            let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
            
            if searchBar.text == "" && scope != "ALL" {
                stockItem = filteredStockItems[indexPath.row]
            }
            else if searchBar.text == "" && scope == "ALL" {
                stockItem = stockItems![indexPath.row]
            }
            else if searchBar.text != "" && scope == "ALL" {
                stockItem = filteredStockItems[indexPath.row]
            }
            else {
                //searchBar.text != "" && scope != "ALL" is true
                stockItem = filteredStockItems[indexPath.row]
            }
        }
        else {
            stockItem = stockItems![indexPath.row]
        }
        
        
        //TODO: do away with stockItems
        
        let _item = stocktake?.getSingularStockItem(stockItem.invCode)
        let _itemPhoto = stocktake?.getStockItemPhoto(stockItem.invCode)
        //print("DEBUGGING")
        //print(stocktake)
        //print(_item)
        //print("END DEBUGGING")
        
        // Configure the cell...
        
        cell.stockPhotoImageView.image = _itemPhoto
        cell.stockPhotoImageView.layer.cornerRadius = cell.stockPhotoImageView.frame.size.width / 2.0
        cell.stockPhotoImageView.clipsToBounds = true
        cell.stockDescriptionLabel.text = _item?.itemDescription.uppercaseString
            
        let sub1 = "ID: "
        let sub2 = String((_item?.invCode)!)
        let sub3 = " /// $"
        let sub4 = String((_item?.lastCost)!)
        let sub5 = " per "
        let sub6 = (_item?.units)!
        cell.stockFineDetailsLabel.text = sub1 + sub2 + sub3 + sub4 + sub5 + sub6
        
        
        if _item?.physicalAmount != 0 {
            cell.stockRunningAmountLabel.text = String((_item?.physicalAmount)!)
            cell.stockRunningCostLabel.text = "$" + String((_item?.physicalAmount)! * (_item?.lastCost)!)
            cell.stockRunningAmountLabel.backgroundColor = UIColor.orangeColor()
            cell.stockRunningCostLabel.backgroundColor = UIColor.orangeColor()
        }
        else {
            cell.stockRunningAmountLabel.text = "0.0"
            cell.stockRunningCostLabel.text = "$0.0"
            cell.stockRunningAmountLabel.backgroundColor = UIColor.grayColor()
            cell.stockRunningCostLabel.backgroundColor = UIColor.grayColor()
        }
        
        cell.stockRunningAmountLabel.layer.masksToBounds = true
        cell.stockRunningAmountLabel.layer.cornerRadius = 8.0
        cell.stockRunningCostLabel.layer.masksToBounds = true
        cell.stockRunningCostLabel.layer.cornerRadius = 8.0
        cell.backgroundColor = UIColor(red: 38.0/255, green: 38.0/255, blue: 38.0/255, alpha: 1.0)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    
    func updateStocktakeDetails() {
        //StocktakeDetailsViewController calls this method
        //when the user selects 'Save' button in the details VC
        tableView.reloadData()
    }
    
    

    /*
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        print("identifier is: \(identifier)")
        
        if identifier == "unwindToStocktakeSummary" {
            print("unwindToStocktakeSummary")
            return true
        }
        else if identifier == "showStockItemDetails"{
            print("showStockItemDetails")
            return true
        }
        else {
            return false
        }
    }
    */
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showStockItemDetails" {
            let stockItemDetailViewController = segue.destinationViewController as! StockItemDetailsViewController
            
            // get the cell that generated the segue
            if let selectedStockCell = sender as? StockItemTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedStockCell)!
                let stockItem: StockItem
                
                //must factor into the segue whether user selected after searching or no
                if searchController.active {
                    let searchBar = searchController.searchBar
                    let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
                    
                    if searchBar.text == "" && scope != "ALL" {
                        stockItem = filteredStockItems[indexPath.row]
                    }
                    else if searchBar.text == "" && scope == "ALL" {
                        stockItem = stockItems![indexPath.row]
                    }
                    else if searchBar.text != "" && scope == "ALL" {
                        stockItem = filteredStockItems[indexPath.row]
                    }
                    else {
                        //searchBar.text != "" && scope != "ALL" is true
                        stockItem = filteredStockItems[indexPath.row]
                    }
                }
                else {
                    stockItem = stockItems![indexPath.row]
                }
                
                //ASSING THE STOCKTAKE OBJECT TO DETAILS VC
                stockItemDetailViewController.stockTake = stocktake
                
                //get the stocktakeItemMO for the particular invCode from core data
                //then pass it along to destination VC
                let stockItemMO: StocktakeItemMO? = stocktake?.getSingularStockItem(stockItem.invCode)
                
                //print("YOYOYOY: stockItemMO is: \(stockItemMO)")
                
                stockItemDetailViewController.stockItemMO = stockItemMO
            }
        }
        else if segue.identifier == "showStocktakeSummary" {
            let navVC = segue.destinationViewController as! UINavigationController
            print("navVC.viewControllers are \(navVC.viewControllers)")
            
            let summaryVC = navVC.viewControllers.first as! StocktakeSummaryViewController
            summaryVC.stocktake = stocktake
        }
    }
    
    
}