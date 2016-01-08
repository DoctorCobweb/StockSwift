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
    
    @IBOutlet weak var department: UIButton!
    @IBOutlet weak var personName: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //add a bar button programmatically and set
        //its action/target pair
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelNewStocktake:")
        personName.delegate = self
        
        //set a default time of now.
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let strDate =  dateFormatter.stringFromDate(datePicker.date)
        stocktakeMetadata["date"] = strDate
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
            self.stocktakeMetadata["department"] = "kitchen"
        }
        let bottleshopAction = UIAlertAction(title:"Bottleshop", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = "bottleshop"
        }
        let gamingAction = UIAlertAction(title:"Gaming", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = "gaming"
        }
        let restaurantAction = UIAlertAction(title:"Restaurant", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = "restaurant"
        }
        let barAction = UIAlertAction(title:"Bar", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = "bar"
        }
        let tabAction = UIAlertAction(title:"Tab", style:.Default) {(action) in print(action)
            self.stocktakeMetadata["department"] = "tab"
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
        stocktakeMetadata["person_name"] = text
        startButton.enabled = !text.isEmpty
        //checkValidFieldName()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // disable save button while editing
        //saveButton.enabled = false
    }
    
    func checkValidFieldName() {
        //disable the save button if the text is empty
        let text = personName.text ?? ""
        startButton.enabled = !text.isEmpty
    }
    
    @IBAction func datePickerAction(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let strDate =  dateFormatter.stringFromDate(sender.date)
        print(" in dataPickerAction and strDate is \(strDate)")
        
        stocktakeMetadata["date"] = strDate
    }
    
    // MARK: - Navigation
    
    @IBAction func cancelNewStocktake(sender: AnyObject) {
       navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func startStocktake(sender: UIButton) {
        print("in startStocktake")
        
        //only perform segue if personName, department and date are set properly
        if stocktakeMetadata["person_name"] != nil && stocktakeMetadata["department"] != nil {
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
        print("in prepareForSegue")
        print(stocktakeMetadata)
    }
}
