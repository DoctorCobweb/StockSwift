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
    @IBOutlet weak var scrollView: UIScrollView!
    
    var stockItemMO: StocktakeItemMO?
    var amountsBuffer:[Float] = []
    var amtTableView: UITableView?
    var stocktake: Stocktake?
    var activeField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title! = "Stock Item Details"
        
        newStockAmountTextField.attributedPlaceholder = NSAttributedString(string: "Type here", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        newStockAmountTextField.keyboardType = .DecimalPad
        
        addDoneButtonOnKeyboard()
        registerForKeyboardNotifications()
        
        
        saveButton.enabled = false
        
        if let item = stockItemMO {
            stockDescriptionLabel.text = item.itemDescription
            stockFineDetailLabel.text = "ID: " + String(item.invCode) + " /// $" + String(item.lastCost) + " per " + item.units
            stockPhotoImageView.image = stocktake?.getStockItemPhoto(item.invCode)
            stockPhysicalAmountLabel.text = String(item.physicalAmount)
            stockMoneyAmountLabel.text = String(item.physicalAmount * item.lastCost)
        }
        newStockAmountTextField.delegate = self
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0,0,320,50))
        doneToolbar.barStyle = UIBarStyle.Default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "doneButtonAction")
        let orange = UIColor(red: 255.0/255, green: 153.0/255, blue: 45.0/255, alpha: 1.0)
        done.tintColor = orange
        
        var items: [UIBarButtonItem] = []
        items += [flexSpace]
        items += [done]
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        newStockAmountTextField.inputAccessoryView = doneToolbar
    }
    
    func doneButtonAction() {
        newStockAmountTextField.resignFirstResponder()
    }
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //called when UIKeyboardDidShowNotification is sent
    func keyboardWasShown(aNotification: NSNotification) {
        let info = aNotification.userInfo!
        let kbFrame = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        
        print("kbFrame is \(kbFrame)")
        
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbFrame.height, 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        //if active field is hidden by kb then scroll so it's visible
        var aRect: CGRect = self.view.frame
        aRect.size.height -= kbFrame.height
        
        if (!CGRectContainsPoint(aRect, activeField!.frame.origin)) {
            scrollView.scrollRectToVisible(activeField!.frame, animated:true)
        }
    }
    
    //called when UIKeyboardWillHideNotification is sent
    func keyboardWillBeHidden(aNotification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    
    // MARK: UITextFieldDelegate protocol methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
        newStockAmountTextField.placeholder = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //text field should resign as first responder to hide
        //the keyboard
        newStockAmountTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
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
                
                
                let netStock = (stockItemMO?.physicalAmount)! + bufferSum
                stockPhysicalAmountLabel.text = String(netStock)
                stockMoneyAmountLabel.text = String(netStock * (stockItemMO?.lastCost)!)
                
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
            
            let netStock = (stockItemMO?.physicalAmount)! + bufferSum
            stockPhysicalAmountLabel.text = String(netStock)
            stockMoneyAmountLabel.text = String(netStock * (stockItemMO?.lastCost)!)
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
        //print(amtTableView?.delegate)
        
        if amtTableView?.editing == true {
            let attrStr = NSAttributedString(string:"Edit", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            sender.setAttributedTitle(attrStr, forState: UIControlState.Normal)
            amtTableView?.setEditing(false, animated: true)
        }
        else {
            let attrStr = NSAttributedString(string:"Done", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            sender.setAttributedTitle(attrStr, forState: UIControlState.Normal)
            
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
        //that's from a navigation controller. pop it like a pop tart.
        navigationController!.popViewControllerAnimated(true)
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("in StockItemDetailsViewController, prepareForSegue()")
    }
    
    @IBAction func saveStock(sender: UIBarButtonItem) {
        
        //print(navigationController!.viewControllers)
        //print(navigationController?.topViewController)
        
        //get the StocktakeTableViewController using force casting
        let sourceViewController = navigationController!.viewControllers[navigationController!.viewControllers.count - 2] as! StocktakeTableViewController
        
        let _newAmount = amountsBuffer.reduce(0, combine: {(run, elem) in (run+elem)})
        
        
        print("_newAmount: \(_newAmount)")
        //update the stock amount in Core Data
        stocktake?.updateStockItem((stockItemMO?.invCode)!, amount: _newAmount)
        
        
        
        
        sourceViewController.updateStocktakeDetails() //reloads the table view
        
        navigationController!.popViewControllerAnimated(true)
    }
}