//
//  SettingsEmailViewController.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 09/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class SettingsEmailViewController: UIViewController {

    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    var currentUser = PFUser()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = PFUser.currentUser()!
        
        emailInput.text = currentUser.email
        
        emailInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if((emailInput.text?.characters.count)! > 0 && emailInput.text != currentUser.email) {
            saveButton.hidden = false
        }
        else {
            saveButton.hidden = true
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        saveButton.enabled = false
        saveButton.titleLabel?.text = "SAVING..."
        
        currentUser.email = emailInput.text
        currentUser.saveInBackgroundWithBlock { (suceeded: Bool, error: NSError?) -> Void in
            if(error == nil) {
                self.navigationController?.popViewControllerAnimated(true)
            }
            else {
                self.saveButton.enabled = true
                self.saveButton.titleLabel?.text = "SAVE"
            }
        }
    }



}
