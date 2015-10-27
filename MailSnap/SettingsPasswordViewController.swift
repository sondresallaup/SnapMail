//
//  SettingsPasswordViewController.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 09/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class SettingsPasswordViewController: UIViewController {

    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var passwordHintLabel: UILabel!
    
    
    var correctPassword: Bool = false
    
    var currentUser = PFUser()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = PFUser.currentUser()!
        
        passwordInput.becomeFirstResponder()
        
        passwordInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if(!correctPassword) {
            if((passwordInput.text?.characters.count)! > 0) {
                continueButton.hidden = false
            }
            else {
                continueButton.hidden = true
            }
        }
        else {
            if((passwordInput.text?.characters.count)! == 4) {
                continueButton.enabled = true
            }
            else {
                continueButton.enabled = false
            }
        }
        
    }
    
    @IBAction func continueButtonClicked(sender: AnyObject) {
        if(!correctPassword) {
            continueButton.enabled = false
            continueButton.titleLabel?.text = "LOADING..."
        
            PFUser.logInWithUsernameInBackground(currentUser.username!, password: passwordInput.text!) { (user: PFUser?, error: NSError?) -> Void in
                if(error == nil) {
                    self.passwordInput.placeholder = "Create new password"
                    self.passwordInput.text = ""
                    self.continueButton.titleLabel?.text = "SAVE"
                    self.passwordHintLabel.text = "Set a good password by using a combination of lowecase and uppercase letters, numbers and symbols."
                
                    self.correctPassword = true
                }
                else {
                    self.continueButton.enabled = true
                    self.continueButton.titleLabel?.text = "CONTINUE"
                    let alert = UIAlertView()
                    alert.title = "Error"
                    alert.message = "Wrong password"
                    alert.addButtonWithTitle("Got it")
                    alert.show()
                }
            }
        }
        else {
            continueButton.enabled = false
            continueButton.titleLabel?.text = "SAVING..."
            currentUser.password = passwordInput.text
            currentUser.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                if(error == nil) {
                    self.navigationController?.popViewControllerAnimated(true)
                }
                else {
                    self.continueButton.enabled = true
                    self.continueButton.titleLabel?.text = "SAVE"
                    let alert = UIAlertView()
                    alert.title = "Error"
                    alert.message = error?.localizedDescription
                    alert.addButtonWithTitle("Got it")
                    alert.show()
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
