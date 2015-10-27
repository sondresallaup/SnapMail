//
//  SignUpUsernameViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 06/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit

class SignUpUsernameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    var fullName: String!
    var email: String!
    var streetAddress: String!
    var zipNumber: String!
    var postalArea: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        usernameInput.becomeFirstResponder()
        usernameInput.delegate = self
    }
    
    func textFieldDidChange(textField: UITextField) {
        if(usernameInput.text?.characters.count > 3) {
            nextButton.enabled = true
        }
        else {
            nextButton.enabled = false
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(usernameInput.text?.characters.count > 3) {
            self.performSegueWithIdentifier("usernameToPassword", sender: self)
            return true
        }
        else {
            return false
        }
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "usernameToPassword") {
            if let viewController: SignUpPasswordViewController = segue.destinationViewController as? SignUpPasswordViewController {
                viewController.fullName = fullName
                viewController.email = email
                viewController.streetAddress = streetAddress
                viewController.zipNumber = zipNumber
                viewController.postalArea = postalArea
                viewController.username = usernameInput.text
            }
        }
    }

}
