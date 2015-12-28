//
//  StocktakeTableViewController.swift
//  StockSwift
//
//  Created by andre trosky on 27/12/2015.
//  Copyright © 2015 andre trosky. All rights reserved.
//

import UIKit

class StocktakeTableViewController: UITableViewController {

    // MARK: Properties
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var stockItems = [StockItem]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        loadStocktakeItems()
    }
    
    func loadStocktakeItems() {
        
        //first load and parse the csv data file, "stock_data"
        let stockContent = parseStockDataCSV()
        
        //stockContent is (headers, data) structure
        //print(stockContent.headers)
        print(stockContent.data![0].description)
        
        //instantiate a stock item for each item in stockContent.data
        for item in stockContent.data! {
            print(item.description)
            print(item.inv_code)
            print(item.last_cost!)
            let photo = UIImage(named: "stock1")
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
    
    func loadHardcodedStocktakeItems() {
        
        let photo1 = UIImage(named: "stock1")
        let stockItem1 = StockItem(
            photo: photo1,
            description: "beef porterhouse",
            invCode: 101114,
            lastCost: 23.4,
            units: "Kilogram",
            section: "Beef")
        
        let photo2 = UIImage(named: "stock2")
        let stockItem2 = StockItem(
            photo: photo2,
            description: "chicken fillet",
            invCode: 101101,
            lastCost: 10.2,
            units: "Kilogram",
            section: "Poultry")
        
        let photo3 = UIImage(named: "stock3")
        let stockItem3 = StockItem(
            photo: photo3,
            description: "atlantic salmon",
            invCode: 143888,
            lastCost: 51.1,
            units: "Kilogram",
            section: "Seafood")
        
        stockItems += [stockItem1, stockItem2, stockItem3]
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
                        // Put the values into the tuple and add it to the items array
                        let item = (stock_group: values[0],
                                    stock_group_cleaned: values[1],
                                    inv_code: Int(values[2]),
                                    description: values[3],
                                    units: values[4],
                                    last_cost: Float(values[5]),
                                    barcode: values[6])
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

    
    
    /*
    //OLD NOT USED
    func getContentsOfURL() -> String? {
        if let path = NSBundle.mainBundle().pathForResource("assets/stock_data", ofType: "csv") {
            do {

                return try String(contentsOfURL: NSURL(fileURLWithPath: path), encoding: NSUTF8StringEncoding) as String
                //return try String(contentsOfFile: "stock_data", encoding:NSUTF8StringEncoding) as String
            } catch {
                print("caught a nil in getContentsOfURL")
                return nil
            }
        }
        else {
            return nil
        }
    }
    */

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
        // #warning Incomplete implementation, return the number of rows
        return stockItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "StockItemTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! StockItemTableViewCell
        let stockItem = stockItems[indexPath.row]

        // Configure the cell...
        cell.stockPhotoImageView.image = stockItem.photo
        cell.stockDescriptionLabel.text = stockItem.description.uppercaseString
        cell.stockFineDetailsLabel.text = "ID: " + String(stockItem.invCode) + " /// $" + String(stockItem.lastCost) + " per " + stockItem.units

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
                let selectedStockItem = stockItems[indexPath.row]
                stockItemDetailViewController.stockItem = selectedStockItem
            }
        
        
        
        }
        
    }

}
