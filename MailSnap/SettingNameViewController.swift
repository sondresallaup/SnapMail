//
//  SettingNameViewController.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 09/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class SettingNameViewController: UIViewController {

    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var currentUser = PFUser()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = PFUser.currentUser()!
        
        nameInput.text = currentUser.valueForKey("name") as? String
        
        nameInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if((nameInput.text?.characters.count)! > 0 && nameInput.text != currentUser.valueForKey("name") as? String) {
            saveButton.hidden = false
        }
        else {
            saveButton.hidden = true
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        saveButton.enabled = false
        saveButton.titleLabel?.text = "SAVING..."
        
        currentUser["name"] = nameInput.text
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
