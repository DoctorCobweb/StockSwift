//
//  StocktakeTableViewController.swift
//  StockSwift
//
//  Created by andre trosky on 27/12/2015.
//  Copyright © 2015 andre trosky. All rights reserved.
//

import UIKit


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
    var stockItems = [StockItem]()
    var filteredStockItems = [StockItem]()
    
    
    //contains all the stock items added for each invCode value.
    //every time a user saves an amount in details view, the value gets appended to
    //the array for that invCode item.
    //the floats are the amounts, NOT money amounts.
    var runningStocktakeDict =  [Int: [Float]]()
    
    //putting nil for searchResultsController tells the app that you want to use the same view your searching in to also display the results.
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        navigationItem.title = "New Stocktake"
        //navigationItem.leftBarButtonItem?.title = "Save Stocktake"
        //print(navigationItem.leftBarButtonItem)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        
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
        
        //finally load in the stock items
        loadStocktakeItems()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "ALL") {
        //print("filterContentForSearchText and searchText: " + searchText)
        
        //this filters stockItems array based on the searchText string and will put the results into filteredStockItems array.
        //
        //filter() takes a closure of type (item:StockItem) -> Bool
        //then it loops over all elements of the array, calls the closure passing in the current element,
        //if true is returned for that element it is added to filteredStockItems
        filteredStockItems = stockItems.filter { item in
            
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
    
    func loadStocktakeItems() {
        
        //first load and parse the csv data file, "stock_data", then sort it alphabettically
        //using description field
        let stockContent = parseStockDataCSV()
        let stockHeaders:[String] = stockContent.headers
        let stockContent_sorted = stockContent.data!.sort{$0.description < $1.description}
        
        //stockContent is (headers, data) structure
        //print(stockHeaders)
        
        //instantiate a stock item for each item in stockContent.data
        //for (index, item) in stockContent.data!.enumerate() {
        for (index, item) in stockContent_sorted.enumerate() {
            //print(item.description)
            //print(item.inv_code)
            //print(item.last_cost!)
            
            let photo:UIImage?
            
            
            //just playing around with different images
            if index % 3 == 0 {
                photo = UIImage(named:"stock3")!
            }
            else if index % 5 == 0 {
                photo = UIImage(named:"stock2")!
            }
            else if index % 7 == 0 {
                photo = UIImage(named:"snow")!
            }
            else {
                photo = UIImage(named: "stock1")!
            }
            
            let stockItem = StockItem(
                photo: photo,
                description: item.description,
                invCode: item.inv_code!,
                lastCost: item.last_cost!,
                units: item.units,
                section: item.stock_group_cleaned)
            
            stockItems += [stockItem]
        }
    
    }
    
    
    func parseStockDataCSV () ->  (headers:[String], data:[(stock_group:String, stock_group_cleaned:String, inv_code:Int?, description:String, units:String, last_cost:Float?, barcode:String)]?) {
        // Load the CSV file and parse it
        let delimiter = ","
        var items: [(stock_group:String,
                     stock_group_cleaned:String,
                     inv_code:Int?,
                     description:String,
                     units:String,
                     last_cost:Float?,
                     barcode:String)]?
        
        //get the stock_data from the assests folder
        let stock_data = NSDataAsset(name:"stock_data")
        var headers = [String]()
        
        //stock_data!.data is raw byte data so we must convert it to String using the following initializer
        
        if let content = String(data:stock_data!.data, encoding:NSUTF8StringEncoding) {
            items = []
            let lines:[String] = content.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) as [String]
            
            for (index,line) in lines.enumerate() {
                //print(index)
                var values:[String] = []
                if line != "" {
                    // For a line with double quotes
                    // we use NSScanner to perform the parsing
                    if line.rangeOfString("\"") != nil {
                        var textToScan:String = line
                        var value:NSString?
                        var textScanner:NSScanner = NSScanner(string: textToScan)
                        while textScanner.string != "" {
                            
                            if (textScanner.string as NSString).substringToIndex(1) == "\"" {
                                textScanner.scanLocation += 1
                                textScanner.scanUpToString("\"", intoString: &value)
                                textScanner.scanLocation += 1
                            } else {
                                textScanner.scanUpToString(delimiter, intoString: &value)
                            }
                            
                            // Store the value into the values array
                            values.append(value as! String)
                            
                            // Retrieve the unscanned remainder of the string
                            if textScanner.scanLocation < textScanner.string.characters.count {
                                textToScan = (textScanner.string as NSString).substringFromIndex(textScanner.scanLocation + 1)
                            } else {
                                textToScan = ""
                            }
                            textScanner = NSScanner(string: textToScan)
                        }
                        
                        // For a line without double quotes, we can simply separate the string
                        // by using the delimiter (e.g. comma)
                    }
                    else  {
                        values = line.componentsSeparatedByString(delimiter)
                    }
                    
                    if index == 0 {
                        //we have the header line
                        headers = values
                    }
                    else {
                        
                        //trim whitespace and newlines from strings
                        let stock_group_tmp = values[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        var stock_group_cleaned_tmp = values[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        let description_tmp = values[3].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        let units_tmp = values[4].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        let barcode_tmp = values[6].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        
                        
                        //change stock group categories to make a smaller number of categories.
                        //need to do this so the search bar scope terms are not too many and hence display bad/small
                        let meat_set: Set = ["POULTRY", "BEEF", "PORK", "LAMB", "SEAFODD"]
                        let other_set: Set = ["DESSERT", "BEVERAGE"]
                        stock_group_cleaned_tmp = meat_set.contains(stock_group_cleaned_tmp) ? "MEAT" : stock_group_cleaned_tmp
                        stock_group_cleaned_tmp = other_set.contains(stock_group_cleaned_tmp) ? "OTHER" : stock_group_cleaned_tmp
                        
                        
                        // Put the values into the tuple and add it to the items array
                        let item = (stock_group: stock_group_tmp ,
                                    stock_group_cleaned: stock_group_cleaned_tmp,
                                    inv_code: Int(values[2]),
                                    description: description_tmp,
                                    units: units_tmp,
                                    last_cost: Float(values[5]),
                                    barcode: barcode_tmp)
                        items?.append(item)
                    }
                }
            }
        }
        else {
            print("ERROR: unable to read stock_data")
        }
        
        return (headers, items)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                return stockItems.count
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
            return stockItems.count
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
                stockItem = stockItems[indexPath.row]
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
            stockItem = stockItems[indexPath.row]
        }
        
        
        // Configure the cell...
        cell.stockPhotoImageView.image = stockItem.photo
        cell.stockPhotoImageView.layer.cornerRadius = cell.stockPhotoImageView.frame.size.width / 2.0
        cell.stockPhotoImageView.clipsToBounds = true
        
        cell.stockDescriptionLabel.text = stockItem.description.uppercaseString
        cell.stockFineDetailsLabel.text = "ID: " + String(stockItem.invCode) + " /// $" + String(stockItem.lastCost) + " per " + stockItem.units
        
        
        
        //work out the current amount and money for the item
        if let costs = runningStocktakeDict[stockItem.invCode] {
            
            var runningAmt: Float = 0.0
            var runningCost: Float = 0.0
            
            for val in costs {
                runningAmt += Float(val)
                runningCost += Float(val) * stockItem.lastCost
            }
            cell.stockRunningAmountLabel.text = String(runningAmt)
            cell.stockRunningCostLabel.text = "$" + String(runningCost)
            cell.stockRunningAmountLabel.backgroundColor = UIColor.orangeColor()
            cell.stockRunningCostLabel.backgroundColor = UIColor.orangeColor()
        }
        else {
            cell.stockRunningAmountLabel.text = " 0.0"
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
                        stockItem = stockItems[indexPath.row]
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
                    stockItem = stockItems[indexPath.row]
                }
                
                stockItemDetailViewController.stockItem = stockItem
                
                //pass in the current stock amounts to the details page if it exists.
                //otherwise, set it to nil explicitly
                if let amt = runningStocktakeDict[stockItem.invCode] {
                    var runningAmt : Float = 0.0
                    
                    //current stock is in an array.
                    //pass in the summed amount only.
                    for val in amt {
                        runningAmt += Float(val)
                    }
                    
                    stockItemDetailViewController.stockCurrent = [stockItem.invCode: runningAmt]
                }
                else {
                    //have no stock, so set it to nil
                    stockItemDetailViewController.stockCurrent = nil
                }
            }
        }
    }
    
    func updateStocktakeDetails(stockResult: [Int:Float]?) {
        
        for (invCode, amount) in stockResult! {
            if let val = runningStocktakeDict[invCode] {
                //val is not nil and has been unwrapped 
                let updated_amount = val + [amount]
                runningStocktakeDict[invCode] = updated_amount
            }
            else {
                runningStocktakeDict[invCode] = [amount]
            }
        }
        tableView.reloadData()
    }
    
    @IBAction func doneStocktakeFinal(sender: UIBarButtonItem) {
        //print(navigationController?.viewControllers)
        let alertController = UIAlertController(title: "Finish Stocktake?", message: "Select Done if you have finished the stocktake. Otherwise, select cancel to continue with current stocktake", preferredStyle: .Alert)
        let doneAction = UIAlertAction(title: "Done", style: .Default) { (action) in
            print("doneAction selected")
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            print("cancelAction selected")
        }
        
        alertController.addAction(doneAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) { (_) in
        
        
        }
    }
}