//
//  CustomSearchController.swift
//  StockSwift
//
//  Created by andre trosky on 22/01/2016.
//  Copyright © 2016 andre trosky. All rights reserved.
//

import UIKit

class CustomSearchController: UISearchController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let orange = UIColor(red: 255.0/255, green: 153.0/255, blue: 45.0/255, alpha: 1.0)
        searchBar.tintColor = orange

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
