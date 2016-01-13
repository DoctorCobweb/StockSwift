//
//  StockItemDetailsViewController.swift
//  StockSwift
//
//  Created by andre trosky on 28/12/2015.
//  Copyright © 2015 andre trosky. All rights reserved.
//

import UIKit

class StockItemDetailsViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var stockDescriptionLabel: UILabel!
    @IBOutlet weak var stockFineDetailLabel: UILabel!
    @IBOutlet weak var stockPhysicalAmountLabel: UILabel!
    @IBOutlet weak var stockMoneyAmountLabel: UILabel!
    @IBOutlet weak var stockPhotoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var newStockAmountTextField: UITextField!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var editTableViewButton: UIButton!
    
    var stockItem:StockItem?
    var stockCurrent: [Int: Float]?
    var amountsBuffer:[Float] = []
    var amtTableView: UITableView?
    var stockTake: Stocktake?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title! = "Stock Item Details"
        cancelButton.tintColor = UIColor.whiteColor()
        saveButton.tintColor = UIColor.whiteColor()
        newStockAmountTextField.attributedPlaceholder = NSAttributedString(string: "Type here", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        
        saveButton.enabled = false
        
        if let item = stockItem {
            stockDescriptionLabel.text = item.description
            stockFineDetailLabel.text = "ID: " + String(item.invCode) + " /// $" + String(item.lastCost) + " per " + item.units
            stockPhotoImageView.image = item.photo
            
            
            if let res = stockCurrent {
                stockPhysicalAmountLabel.text = String(res[item.invCode]!)
                stockMoneyAmountLabel.text = String(res[item.invCode]! * item.lastCost)
            }
            else {
                stockCurrent = [item.invCode: 0.0]
                stockPhysicalAmountLabel.text = "0.0"
                stockMoneyAmountLabel.text = "0.0"
            }
            
        }
        newStockAmountTextField.delegate = self
        
        
        //PLAYING AROUND AREA: STOCKTAKE OBJET
        print("PLAYING AROUND: \(self.stockTake)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITextFieldDelegate protocol methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        newStockAmountTextField.placeholder = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //text field should resign as first responder to hide
        //the keyboard
        newStockAmountTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //gives us a chance to read the value in the text field
        let entry = textField.text ?? ""
        
        if !entry.isEmpty {
            if let numberEntered = Float(entry) {
                
                //if first time user entered a new item create the table view dynamically
                if amountsBuffer.count == 0 {
                    let tFrame = CGRect(x: 0, y: 670, width: 300, height: 30)
                    print(tFrame)
                    amtTableView = UITableView(frame: tFrame)
                    newStockAmountTextField.superview?.addSubview(amtTableView!)
                    amtTableView?.delegate = self
                    amtTableView?.dataSource = self
                }
                
                amountsBuffer.append(numberEntered)
                
                //configure the table view
                amtTableView?.rowHeight = 30
                
                //whenever a new item is added to amountsBuffer make sure the frame
                //of table view is high enough.
                amtTableView?.frame = CGRect(x: 0.0, y: 670.0, width: 300.0, height: (amtTableView?.rowHeight)! * CGFloat(amountsBuffer.count))
                amtTableView?.reloadData()
                
                saveButton.enabled = true
                
                let bufferSum = amountsBuffer.reduce(0, combine: {(run, elem) in (run+elem)})
                
                if let current = stockCurrent {
                    let netStock = bufferSum + current[stockItem!.invCode]!
                    stockPhysicalAmountLabel.text = String(netStock)
                    stockMoneyAmountLabel.text = String(netStock * stockItem!.lastCost)
                }
                textField.text = ""
            }
            else {
                let alertController = UIAlertController(title: "Error: Invalid Format", message: "Please use a number", preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title:"Okay", style: .Cancel) {
                    (action) in print(action)
                }
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true) {
                }
            }
        }
        print("amountsBuffer \(amountsBuffer)")
    }

    
    
    
    
    
    // MARK: UITableViewDelegate

    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            amountsBuffer.removeAtIndex(indexPath.row)
            amtTableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            //reload data before changing the frame. empty cells are pushed to the
            //bottom and new frame calculations make use of this fact by adjusting the
            //height from same (x,y) position.
            amtTableView?.reloadData()
            amtTableView?.frame = CGRect(x: 0.0, y: 670.0, width: 300.0, height: (amtTableView?.rowHeight)! * CGFloat(amountsBuffer.count))
            
            //should also update the running amounts and money labels since items have
            //been deleted
            let bufferSum = amountsBuffer.reduce(0, combine: {(run, elem) in (run+elem)})
            
            if let current = stockCurrent {
                let netStock = bufferSum + current[stockItem!.invCode]!
                stockPhysicalAmountLabel.text = String(netStock)
                stockMoneyAmountLabel.text = String(netStock * stockItem!.lastCost)
            }
            else {
                stockPhysicalAmountLabel.text = String(bufferSum)
                stockMoneyAmountLabel.text = String(bufferSum * stockItem!.lastCost)
            }
        }
    }
    
    
    
    
    
    
    //MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return amountsBuffer.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        
        cell.textLabel?.text = String(amountsBuffer[indexPath.row])
        return cell
    }
    
    
    
    @IBAction func editTableViewAction(sender: UIButton) {
        print("editTableViewAction")
        print(amtTableView?.delegate)
        
        if amtTableView?.editing == true {
            
            //TODO: this does NOT work, title stays that same
            sender.titleLabel?.text = "Editblah"
            
            amtTableView?.setEditing(false, animated: true)
        }
        else {
            //TODO: this does NOT work, title stays that same
            sender.titleLabel?.text = "Done"
            
            //only set editing if there's a table view present
            if let tableView = amtTableView {
                print(tableView)
                amtTableView?.setEditing(true, animated: true)
            }
        }
    }
    
    

    // MARK: - Navigation

    @IBAction func cancel(sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this
        // view controller needs to be dismissed in two different ways.
        //
        //This creates a Boolean value that indicates whether the view controller 
        //that presented this scene is of type UINavigationController. As the constant 
        //name isPresentingInAddMealMode indicates, this means that the meal scene was 
        //presented using the Add button. This is because the meal scene is embedded in 
        //its own navigation controller when it’s presented in this manner, which 
        //means that navigation controller is what presents it.
        //
        /*
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            print("hello from isPresentingInAddMealMode true block")
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            print("popping viewcontroller off stack")
            navigationController!.popViewControllerAnimated(true)
        }
        */
        
        //for now we know that there's only one way to get to this stock details view, and
        //that' from a navigation controller. just pop it like a pop tart.
        navigationController!.popViewControllerAnimated(true)
        //
        //also, we just disregard the newAmount value if it's nonzero.
        //stockCurrent is the thing we care about and since it's been
        //passed in from StocktakeTableViewController we also don't
        //need to do anything.
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("in StockItemDetailsViewController, prepareForSegue()")
        
        /*
        if saveButton === sender {
            //make a dummy amount for now of 1.234
            stockResult![stockItem!.invCode] = stockItem!.lastCost * 1.234
        }
        */
    }
    
    //TODO: don't rely on indexing the controllers array to get
    //the last controller. use casting and if let procedure
    @IBAction func saveStock(sender: UIBarButtonItem) {
        print(navigationController!.viewControllers)
        let sourceViewController = navigationController!.viewControllers[2] as! StocktakeTableViewController
        let newAmount = [stockItem!.invCode: amountsBuffer.reduce(0, combine: {(run, elem) in (run+elem)})]
        
        sourceViewController.updateStocktakeDetails(newAmount)
        navigationController!.popViewControllerAnimated(true)
    }
}