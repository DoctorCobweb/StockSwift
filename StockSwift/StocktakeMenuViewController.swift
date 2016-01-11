//
//  StocktakeMenuViewController.swift
//  StockSwift
//
//  Created by andre trosky on 8/01/2016.
//  Copyright © 2016 andre trosky. All rights reserved.
//

import UIKit
import CoreData


class StocktakeMenuViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var newStocktake: UIButton!
    @IBOutlet weak var previousStocktakes: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        let orange = UIColor(red: 255.0/255, green: 153.0/255, blue: 45.0/255, alpha: 1.0)
        navigationController?.navigationBar.barTintColor = orange
        menuButton.tintColor = UIColor.whiteColor()
        
        playAroundWithPreviousStocktakes()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newStocktakeAction(sender: UIButton) {
        print("newStocktakeAction function")
    }

    @IBAction func previousStocktakeAction(sender: UIButton) {
        print("previousStocktakeAction function")
    }
    
    func playAroundWithPreviousStocktakes() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        
        let allStocktakeMetaDataFetch = NSFetchRequest(entityName: "StocktakeMetaDataEntity")
        
        do {
        
            let fetchedMetas = try moc.executeFetchRequest(allStocktakeMetaDataFetch) as! [StocktakeMetaDataMO]
            if !fetchedMetas.isEmpty {
                for meta in fetchedMetas {
                    print("-------")
                    print(meta.personName)
                    print(meta.department)
                    print(meta.startDate)
                    print("-------")
                }
            }
        }
        catch let error as NSError {
            fatalError("FAILUR to save context: \(error)")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
