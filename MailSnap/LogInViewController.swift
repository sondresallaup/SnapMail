//
//  LogInViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 25/09/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var loginButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        emailInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        passwordInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        emailInput.becomeFirstResponder()
        emailInput.delegate = self
        passwordInput.delegate = self
    }
    
    func textFieldDidChange(textField: UITextField) {
        if(emailInput.text?.characters.count > 0 && passwordInput.text?.characters.count > 0) {
            loginButton.enabled = true
        }
        else {
            loginButton.enabled = false
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == emailInput && emailInput.text?.characters.count > 0) {
            passwordInput.becomeFirstResponder()
            return true
        }
        else if (textField == passwordInput && emailInput.text?.characters.count > 0 && passwordInput.text?.characters.count > 0) {
            onLoginClicked(self)
            return true
        }
        else {
            return false
        }
    }
    

    @IBAction func onCancelClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func onLoginClicked(sender: AnyObject) {
        PFUser.logInWithUsernameInBackground(emailInput.text!.lowercaseString, password: passwordInput.text!) { (user: PFUser?, error: NSError?) -> Void in
            if(user != nil) {
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.setValue(user, forKey: "user")
                currentInstallation.saveInBackground()
                let mainTabBarView = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
                self.presentViewController(mainTabBarView, animated: true, completion: nil)
            }
            else {
                // Present error message
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

}
