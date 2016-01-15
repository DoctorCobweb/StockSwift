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
    var stocktakeMetadata = [String:String]()
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
        static let dateFormatKey = "dd-MM-yyyy HH:mm"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //add a bar button programmatically and set
        //its action/target pair
        //navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelNewStocktake:")
        //navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        cancelButton.tintColor = UIColor.whiteColor()

        navigationItem.title = "Setup Stocktake"
        
        personName.delegate = self
        
        //set a default time of now.
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = stocktakeMetadataStruct.dateFormatKey
        let strDate =  dateFormatter.stringFromDate(datePicker.date)
        stocktakeMetadata[stocktakeMetadataStruct.startDateKey] = strDate
        
        datePicker.setValue(UIColor.whiteColor(), forKey: "textColor")
        
        personName.attributedPlaceholder = NSAttributedString(string: "Person Name", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        let orange = UIColor(red: 255.0/255, green: 153.0/255, blue: 45.0/255, alpha: 1.0)
        navigationController?.navigationBar.barTintColor = orange
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func selectDepartment(sender: UIButton) {
        
        let alertController = UIAlertController(title:"Department", message:"Select a department for which the stocktake is for.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title:"Cancel", style:.Cancel) {(action) in
            print(action)
        }
        let kitchenAction = UIAlertAction(title:"Kitchen", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = departments.kitchenKey
            self.department.titleLabel?.text = "Kitchen"
        }
        let bottleshopAction = UIAlertAction(title:"Bottleshop", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = departments.bottleshopKey
            self.department.titleLabel?.text = "Bottleshop"
        }
        let gamingAction = UIAlertAction(title:"Gaming", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = departments.gamingKey
            self.department.titleLabel?.text = "Gaming"
        }
        let restaurantAction = UIAlertAction(title:"Restaurant", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = departments.restaurantKey
            self.department.titleLabel?.text = "Restaurant"
        }
        let barAction = UIAlertAction(title:"Bar", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = departments.barKey
            self.department.titleLabel?.text = "Bar"
        }
        let tabAction = UIAlertAction(title:"Tab", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = departments.tabKey
            self.department.titleLabel?.text = "Tab"
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(kitchenAction)
        alertController.addAction(bottleshopAction)
        alertController.addAction(gamingAction)
        alertController.addAction(restaurantAction)
        alertController.addAction(barAction)
        alertController.addAction(tabAction)
        
        self.presentViewController(alertController, animated: true) {
            print("in the presentViewController closure")
        }
    }
    
    // MARK: UITextFieldDelegate
    
    //called when user hits Enter/Done on keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    //called after textField resigns as first responder
    func textFieldDidEndEditing(textField: UITextField) {
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
        print(" in dataPickerAction and strDate is \(strDate)")
        
        stocktakeMetadata[stocktakeMetadataStruct.startDateKey] = strDate
    }
    
    // MARK: - Navigation
    
    @IBAction func cancelNewStocktake(sender: AnyObject) {
       navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func startStocktake(sender: UIButton) {
        print("in startStocktake")
        
        //only perform segue if personName, department and date are set properly
        if stocktakeMetadata[stocktakeMetadataStruct.personNameKey] != nil && stocktakeMetadata[stocktakeMetadataStruct.departmentKey] != nil {
            
            //we setup the stocktake now before the table view is loaded, then
            //pass in the values needed to make table view cells etc. in 
            //prepareForSegue call
            stocktake = Stocktake(metaData: stocktakeMetadata)
            stockItems = stocktake?.loadStockItemsFromCoreData()
            
            performSegueWithIdentifier("startStocktakeSegue", sender: self)
        }
        else {
            let alertController = UIAlertController(title:"Error", message:"Please fill out Person Name and Department.", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title:"Okay", style:.Cancel) {(action) in
                print(action)
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
        
        if segue.identifier == "startStocktakeSegue" {
        
            let stocktakeTableViewController = segue.destinationViewController as! StocktakeTableViewController
            
            //
            //stocktakeTableViewController.stocktakeMetaData = stocktakeMetadata
            stocktakeTableViewController.stocktake = stocktake
            stocktakeTableViewController.stockItems = stockItems
        }
    }
}
