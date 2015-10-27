//
//  SettingsPasswordResetViewController.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 09/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class SettingsPasswordResetViewController: UIViewController {
    
    @IBOutlet weak var resetButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func resetPassword(sender: AnyObject) {
        resetButton.enabled = false
        
        PFUser.requestPasswordResetForEmailInBackground((PFUser.currentUser()?.email)!) { (succeeded: Bool, error: NSError?) -> Void in
            if(error == nil) {
                let alert = UIAlertView()
                alert.title = "Password reset"
                alert.message = "An email with password reset instructions is sent"
                alert.addButtonWithTitle("Got it")
                alert.show()
                
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
            else {
                let alert = UIAlertView()
                alert.title = "Error"
                alert.message = error?.localizedDescription
                alert.addButtonWithTitle("Got it")
                alert.show()
            }
        }
    }

}
