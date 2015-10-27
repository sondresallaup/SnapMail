//
//  SignUpNameViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 25/09/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit

class SignUpNameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        nameInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        nameInput.becomeFirstResponder()
        nameInput.delegate = self
    }
    
    func textFieldDidChange(textField: UITextField) {
        if(nameInput.text?.characters.count > 0) {
            nextButton.enabled = true
        }
        else {
            nextButton.enabled = false
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(nameInput.text?.characters.count > 0) {
            self.performSegueWithIdentifier("nameToEmail", sender: self)
            return true
        }
        else {
            return false
        }
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "nameToEmail") {
            if let viewController: SigUpEmailViewController = segue.destinationViewController as? SigUpEmailViewController {
                viewController.fullName = nameInput.text
            }
        }
    }

    @IBAction func cancelButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
