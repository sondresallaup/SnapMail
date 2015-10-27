//
//  SignUpPasswordViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 25/09/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class SignUpPasswordViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var createAccountButton: UIBarButtonItem!
    
    
    var fullName: String!
    var email: String!
    var streetAddress: String!
    var zipNumber: String!
    var postalArea: String!
    var username: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        passwordInput.becomeFirstResponder()
        passwordInput.delegate = self
    }
    
    func textFieldDidChange(textField: UITextField) {
        if(passwordInput.text?.characters.count == 4) {
            createAccountButton.enabled = true
        }
        else {
            createAccountButton.enabled = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(passwordInput.text?.characters.count == 4) {
            self.onCreateAccountClicked(self)
            return true
        }
        else {
            return false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCreateAccountClicked(sender: AnyObject) {
        createAccountButton.enabled = false
        let user = PFUser()
        user.username = username.lowercaseString
        user.email = email.lowercaseString
        user.password = passwordInput.text
        user["name"] = fullName
        user["street"] = streetAddress
        user["zip"] = zipNumber
        user["postalArea"] = postalArea
        user["wallet"] = 1
        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if(error == nil) {
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.setValue(user, forKey: "user")
                currentInstallation.saveInBackground()
                let tutorialView = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialViewController") as! UINavigationController
                self.presentViewController(tutorialView, animated: true, completion: nil)
            }
            else {
                self.createAccountButton.enabled = true
                // Present error message
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

}
