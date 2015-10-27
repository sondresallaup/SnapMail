//
//  SignUpStreetAddressViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 25/09/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit

class SignUpStreetAddressViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var streetAddressInput: UITextField!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    
    var fullName: String!
    var email: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        streetAddressInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        streetAddressInput.becomeFirstResponder()
        streetAddressInput.delegate = self
    }
    
    func textFieldDidChange(textField: UITextField) {
        if(streetAddressInput.text?.characters.count > 0) {
            nextButton.enabled = true
        }
        else {
            nextButton.enabled = false
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(streetAddressInput.text?.characters.count > 0) {
            self.performSegueWithIdentifier("streetToZip", sender: self)
            return true
        }
        else {
            return false
        }
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "streetToZip") {
            if let viewController: SignUpZipViewController = segue.destinationViewController as? SignUpZipViewController {
                viewController.fullName = fullName
                viewController.email = email
                viewController.streetAddress = streetAddressInput.text
            }
        }
    }

}
