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
        
        
        loadHardcodedStocktakeItems()
    }
    
    
    func loadHardcodedStocktakeItems() {
        
        let photo1 = UIImage(named: "stock1")
        let stockItem1 = StockItem(
            photo: photo1,
            description: "beef porterhouse",
            invCode: 101114,
            lastCost: 23.4,
            units: "Kilogram",
            physicalAmount: 100.1,
            moneyAmount: 300.2)
        
        let photo2 = UIImage(named: "stock2")
        let stockItem2 = StockItem(
            photo: photo2,
            description: "chicken fillet",
            invCode: 101101,
            lastCost: 10.2,
            units: "Kilogram",
            physicalAmount: 12.1,
            moneyAmount: 3322.2)
        
        let photo3 = UIImage(named: "stock3")
        let stockItem3 = StockItem(
            photo: photo3,
            description: "atlantic salmon",
            invCode: 143888,
            lastCost: 51.1,
            units: "Kilogram",
            physicalAmount: 10.2,
            moneyAmount: 414.2)
        
        stockItems += [stockItem1, stockItem2, stockItem3]
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
        // #warning Incomplete implementation, return the number of rows
        return stockItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "StockItemTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! StockItemTableViewCell
        let stockItem = stockItems[indexPath.row]

        // Configure the cell...
        cell.stockPhotoImageView.image = stockItem.photo
        cell.stockDescriptionLabel.text = stockItem.description
        cell.stockInvCodeLabel.text = String(stockItem.invCode)
        cell.stockLastCostLabel.text = String(stockItem.lastCost)
        cell.stockUnitsLabel.text = stockItem.units
        cell.stockPhysicalAmountLabel.text = String(stockItem.physicalAmount)
        cell.stockMoneyAmountLabel.text = String(stockItem.moneyAmount)

        print(cell.stockMoneyAmountLabel.text!)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
