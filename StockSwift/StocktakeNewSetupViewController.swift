//
//  StocktakeNewSetupViewController.swift
//  StockSwift
//
//  Created by andre trosky on 8/01/2016.
//  Copyright © 2016 andre trosky. All rights reserved.
//

import UIKit

class StocktakeNewSetupViewController: UIViewController, UITextFieldDelegate {

    
    //MARK: Properties
    //var stocktakeMetadata = [String:String]()
    //var stocktakeMetadata: [String:String]?
    var stocktakeMetadata: [String:String] = [:]
    var stocktake: Stocktake?
    var stockItems: [StockItem]?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var department: UIButton!
    @IBOutlet weak var personName: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    struct departments {
        static let kitchenKey = "kitchen"
        static let bottleshopKey = "bottleshop"
        static let gamingKey = "gaming"
        static let restaurantKey = "restaurant"
        static let barKey = "bar"
        static let tabKey = "tab"
    }
    
    struct stocktakeMetadataStruct {
        static let personNameKey = "person_name"
        static let departmentKey = "department"
        static let startDateKey = "start_date"
        static let finishDateKey = "finish_date"
        static let dateFormatKey = "dd-MM-yyyy HH:mm:ss"
    }
    
    override func viewWillAppear(animated: Bool) {
        print("in viewWillAppear")
        
        //this HAS to live in viewWillAppear and not in viewDidLoad.
        //that's because when user navigates back to this VC 
        //(from StocktakeTableViewController), viewDidLoad is not called but this method
        //is.
        //we need to reset stocktakeMetadata everytime user comes back to it, otherwise
        //there are CoreData problems with fetching an item.
        //stocktakeMetadata = [:]
        
        //set a default time of now.
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = stocktakeMetadataStruct.dateFormatKey
        let strDate =  dateFormatter.stringFromDate(datePicker.date)
        stocktakeMetadata[stocktakeMetadataStruct.startDateKey] = strDate
        
        datePicker.setValue(UIColor.whiteColor(), forKey: "textColor")
        
        //department.titleLabel?.text = ""
        personName.delegate = self
        personName.text = ""
        personName.attributedPlaceholder = NSAttributedString(string: "Person Name", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        let attrStr = NSAttributedString(string:"Department", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            
        department.setAttributedTitle(attrStr, forState: UIControlState.Normal)
        
        
        
        //print(department.titleLabel?.text)
        /*
        if department.titleLabel?.text == nil {
            
            let attrStr = NSAttributedString(string: "Department", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            
            
            department.setAttributedTitle(attrStr, forState: UIControlState.Normal)
        } else {
            print(stocktakeMetadata)
            
            let attrStr = NSAttributedString(string: (stocktakeMetadata[stocktakeMetadataStruct.departmentKey])!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            
            department.setAttributedTitle(attrStr, forState: UIControlState.Normal)
        
        
        }
        */
    }
    
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //add a bar button programmatically and set
        //its action/target pair
        //navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelNewStocktake:")
        
        navigationItem.title = "Setup Stocktake"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func selectDepartment(sender: UIButton) {
        
        //if a user clicks thru to the department button without hitting enter on keyboard
        //then make sure the personName textfield has resigned as first responder.
        self.textFieldShouldReturn(personName)
        
        let alertController = UIAlertController(title:"Department", message:"Select a department for which the stocktake is for.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title:"Cancel", style:.Cancel) {(action) in
            print(action)
        }
        let kitchenAction = UIAlertAction(title:"Kitchen", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = departments.kitchenKey
            self.department.titleLabel?.text = "Kitchen"
            //let attrStr = NSAttributedString(string:"Kitchen", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            //self.department.setAttributedTitle(attrStr, forState: UIControlState.Selected)
        }
        let bottleshopAction = UIAlertAction(title:"Bottleshop", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = departments.bottleshopKey
            self.department.titleLabel?.text = "Bottleshop"
            //let attrStr = NSAttributedString(string:"Bottleshop", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            //self.department.setAttributedTitle(attrStr, forState: UIControlState.Selected)
        }
        let gamingAction = UIAlertAction(title:"Gaming", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = departments.gamingKey
            self.department.titleLabel?.text = "Gaming"
            //let attrStr = NSAttributedString(string:"Gaming", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            //self.department.setAttributedTitle(attrStr, forState: UIControlState.Selected)
        }
        let restaurantAction = UIAlertAction(title:"Restaurant", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = departments.restaurantKey
            self.department.titleLabel?.text = "Restaurant"
            //let attrStr = NSAttributedString(string:"Restaurant", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            //self.department.setAttributedTitle(attrStr, forState: UIControlState.Selected)
        }
        let barAction = UIAlertAction(title:"Bar", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = departments.barKey
            self.department.titleLabel?.text = "Bar"
            //let attrStr = NSAttributedString(string:"Bar", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            //self.department.setAttributedTitle(attrStr, forState: UIControlState.Selected)
        }
        let tabAction = UIAlertAction(title:"Tab", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = departments.tabKey
            self.department.titleLabel?.text = "Tab"
            //let attrStr = NSAttributedString(string:"Tab", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            //self.department.setAttributedTitle(attrStr, forState: UIControlState.Selected)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(kitchenAction)
        alertController.addAction(bottleshopAction)
        alertController.addAction(gamingAction)
        alertController.addAction(restaurantAction)
        alertController.addAction(barAction)
        alertController.addAction(tabAction)
        
        self.presentViewController(alertController, animated: true) {
        }
    }
    
    // MARK: UITextFieldDelegate
    
    //called when user hits Enter/Done on keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing")
        return true
    }
    
    //called after textField resigns as first responder
    func textFieldDidEndEditing(textField: UITextField) {
        print("textFieldDidEndEditing")
        //disable the save button if the text is empty
        let text = personName.text ?? ""
        stocktakeMetadata[stocktakeMetadataStruct.personNameKey] = text
        startButton.enabled = !text.isEmpty
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // disable save button while editing
        personName.placeholder = ""
    }
    
    
    @IBAction func datePickerAction(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = stocktakeMetadataStruct.dateFormatKey
        let strDate =  dateFormatter.stringFromDate(sender.date)
        
        stocktakeMetadata[stocktakeMetadataStruct.startDateKey] = strDate
    }
    
    // MARK: - Navigation

    @IBAction func startStocktake(sender: UIButton) {
        print("startStocktake")
        
        //only perform segue if personName, department and date are set properly
        if stocktakeMetadata[stocktakeMetadataStruct.personNameKey] != nil && stocktakeMetadata[stocktakeMetadataStruct.departmentKey] != nil {
            
            //we setup the stocktake now before the table view is loaded, then
            //pass in the values needed to make table view cells etc. in 
            //prepareForSegue call
            print("***")
            print(stocktakeMetadata)
            print("***")
            stocktake = Stocktake(metaData: stocktakeMetadata)
            
            //when stocktake first created we must call startup to set ti up.
            //later on when a user wants to visit an old 
            //stocktake in StocktakeMenuTableViewController we _don't_ call startup.
            //
            //if you do then you will duplicate the stocktake and polute core data 
            //with duplicate stocktakes. bad
            stocktake?.startup()
            stockItems = stocktake?.loadStockItemsFromCoreData()
            
            //print("NEW SETUP DEBUGGING")
            //print(stocktakeMetadata)
            //print(stocktake)
            //print(stockItems)
            //print("END NEW SETUP DEBUGGING")
            
            //then reset the stocktakeMetaData
            
            performSegueWithIdentifier("startStocktakeSegue", sender: self)
        }
        else {
            let alertController = UIAlertController(title:"Error", message:"Please fill out Person Name and Department.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title:"Okay", style:.Cancel) {(action) in
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true) {
                
            }
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("StocktakeNetSetupViewController, prepareForSegue...")
        
        if segue.identifier == "startStocktakeSegue" {
            print("...prepareForSegue, startStocktakeSegue")
        
            let stocktakeTableViewController = segue.destinationViewController as! StocktakeTableViewController
            
            //
            //stocktakeTableViewController.stocktakeMetaData = stocktakeMetadata
            stocktakeTableViewController.stocktake = stocktake
            stocktakeTableViewController.stockItems = stockItems
        }
    }
}
