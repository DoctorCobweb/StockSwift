//
//  StocktakeMenuViewController.swift
//  StockSwift
//
//  Created by andre trosky on 8/01/2016.
//  Copyright © 2016 andre trosky. All rights reserved.
//

import UIKit

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
        let blah = UIColor(red: 255.0/255, green: 153/255, blue: 45.0/255, alpha: 0.0)
        navigationController?.navigationBar.barTintColor = blah
        //navigationController?.navigationBar.barTintColor = UIColor(red: 255.0, green: 10.0, blue: 100.0, alpha: 1.0)
        //navigationController?.navigationBar.backgroundColor = UIColor(red: 255.0, green: 255.0, blue: 12.1, alpha: 0.3)
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
