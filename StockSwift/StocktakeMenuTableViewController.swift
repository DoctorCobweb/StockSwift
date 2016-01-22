//
//  StocktakeMenuTableViewController.swift
//  StockSwift
//
//  Created by andre trosky on 15/01/2016.
//  Copyright © 2016 andre trosky. All rights reserved.
//

import UIKit
import CoreData

class StocktakeMenuTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    var fetchedResultsController: NSFetchedResultsController!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
        initializeFetchedResultsController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initializeFetchedResultsController() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        
        let request = NSFetchRequest(entityName: "StocktakeMetaDataEntity")
        let departmentSort = NSSortDescriptor(key: "department", ascending: true)
        let personSort = NSSortDescriptor(key: "personName", ascending: true)
        request.sortDescriptors = [departmentSort, personSort]
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath:"department", cacheName: nil)
        
        //the delegate will notify the table VC of any changes to the underlying 
        //data in core data.
        self.fetchedResultsController.delegate = self
        
        do {
            //performFetch gets the initial data needed for display and also begins
            //monitoring the managed object context for any changes.
            try self.fetchedResultsController.performFetch()
        }
        catch {
            fatalError("failed to initialize FetchedResultsController. \(error)")
        }
    }
    

    // MARK: - Table view data source
    
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let stocktakeMetaData = self.fetchedResultsController.objectAtIndexPath(indexPath) as! StocktakeMetaDataMO
        let separator = " /// "
        let sub1 = stocktakeMetaData.personName
        let sub2 = stocktakeMetaData.startDate
        
        cell.textLabel?.text = sub1 + separator + sub2
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections!.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sections = self.fetchedResultsController.sections as [NSFetchedResultsSectionInfo]?
        let sectionInfo = sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("metaDataCell", forIndexPath: indexPath)
        
        //setup the cell
        self.configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.fetchedResultsController.sections![section].name.uppercaseString
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
    
    
    
    // MARK: NSFetchedResultsControllerDelegate protocol methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            self.configureCell(self.tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            self.tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    @IBAction func unwindCancelStocktake(sender: UIStoryboardSegue) {
        print("unwindToMenuTableVC func called")
        if sender.identifier == "unwindCancelStocktake" {
            let sourceVC = sender.sourceViewController as! StocktakeNewSetupViewController
        }
        
        /*
        if sender.identifier == "unwindStocktakeToMenuVC" {
            let sourceVC = sender.sourceViewController as! StocktakeTableViewController
            print(sourceVC.stockItems?.count)
            
            //TODO
            //send off email using a popover or something like a big alert view
        }
        */
    }
    
    @IBAction func unwindFinishStocktake(sender: UIStoryboardSegue) {
        print("unwindFinishStocktake")
        
        if sender.identifier == "unwindFinishStocktake" {
            let sourceVC = sender.sourceViewController as! StocktakeSummaryViewController
            var metaInfo = ""
            
            if let meta = sourceVC.stocktake?.stocktakeMetaData {
                metaInfo = meta["department"]! + " /// " + meta["person_name"]! + " /// " + meta["start_date"]!
            }
            
            let alertController = UIAlertController(title: "STOCKTAKE DONE", message: "You have completed the stocktake for \n\n\(metaInfo)", preferredStyle: .Alert)
            
            let okayAction = UIAlertAction(title: "Cheers", style: .Default) { (action) in print(action)
            }
            
            alertController.addAction(okayAction)
            
            //delay the execution until the next run loop because the table view is not
            //yet available. a work around from:
            //http://stackoverflow.com/questions/24854802/presenting-a-view-controller-modally-from-an-action-sheets-delegate-in-ios8-ios
            dispatch_async(dispatch_get_main_queue()) { _ in
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }

}
