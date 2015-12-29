//
//  StockItemDetailsViewController.swift
//  StockSwift
//
//  Created by andre trosky on 28/12/2015.
//  Copyright © 2015 andre trosky. All rights reserved.
//

import UIKit

class StockItemDetailsViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var stockDescriptionLabel: UILabel!
    @IBOutlet weak var stockFineDetailLabel: UILabel!
    @IBOutlet weak var stockPhysicalAmountLabel: UILabel!
    @IBOutlet weak var stockMoneyAmountLabel: UILabel!
    @IBOutlet weak var stockPhotoImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var newStockAmountTextField: UITextField!
    
    var stockItem:StockItem?
    var stockResult = [Int: Float]()

    override func viewDidLoad() {
        super.viewDidLoad()
        //print(stockItem!.description)
        
        navigationItem.title! = "Stock Item Details"
        
        if let item = stockItem {
          stockDescriptionLabel.text = item.description
          stockFineDetailLabel.text = "ID: " + String(item.invCode) + " /// $" + String(item.lastCost) + " per " + item.units
          stockPhotoImageView.image = item.photo
        }
        
        newStockAmountTextField.delegate = self
        
    }
    
    // MARK: UITextFieldDelegate protocol methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //text field should resign as first responder to hide
        //the keyboard
        newStockAmountTextField.resignFirstResponder()
        return true
    }
    
    //TODO: error/formatting checking
    func textFieldDidEndEditing(textField: UITextField) {
        //gives us a chance to read the value in the text field
        if let entry = textField.text {
            if entry != "" {
                let numberEntered = Float(textField.text!)!
                let calculatedMoney = numberEntered * stockItem!.lastCost
                stockPhysicalAmountLabel.text = textField.text
                stockMoneyAmountLabel.text = String(calculatedMoney)
                stockResult[stockItem!.invCode] = numberEntered * stockItem!.lastCost
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("prepareForSegue")
        
        /*
        if saveButton === sender {
            //make a dummy amount for now of 1.234
            stockResult![stockItem!.invCode] = stockItem!.lastCost * 1.234
        }
        */
    }
    
    @IBAction func saveStock(sender: UIBarButtonItem) {
        let sourceViewController = navigationController!.viewControllers[0] as! StocktakeTableViewController
        
        sourceViewController.updateStocktakeDetails(stockResult)
        navigationController!.popViewControllerAnimated(true)
    }
    
    
    

}
