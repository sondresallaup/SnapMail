//
//  CustomNavtigationViewController.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 09/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit

class CustomNavtigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //let barTintColor = UIColo
        
        self.navigationBar.barTintColor = UIColor.orangeColor()
        //self.navigationBar.titleTextAttributes =
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
