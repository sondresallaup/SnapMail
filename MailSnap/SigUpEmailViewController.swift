//
//  SigUpEmailViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 25/09/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit

class SigUpEmailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    var fullName: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        emailInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        emailInput.becomeFirstResponder()
        emailInput.delegate = self
    }
    
    func textFieldDidChange(textField: UITextField) {
        if(emailInput.text?.characters.count > 0 && isValidEmail(emailInput.text!)) {
            nextButton.enabled = true
        }
        else {
            nextButton.enabled = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(emailInput.text?.characters.count > 0 && isValidEmail(emailInput.text!)) {
            self.performSegueWithIdentifier("emailToStreet", sender: self)
            return true
        }
        else {
            return false
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "emailToStreet") {
            if let viewController: SignUpStreetAddressViewController = segue.destinationViewController as? SignUpStreetAddressViewController {
                viewController.fullName = fullName
                viewController.email = emailInput.text
            }
        }
    }

}
