//
//  SignUpZipViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 25/09/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit

class SignUpZipViewController: UIViewController, UITextFieldDelegate, NSXMLParserDelegate {
    
    @IBOutlet weak var zipNumberInput: UITextField!
    @IBOutlet weak var createAccountButton: UIBarButtonItem!
    @IBOutlet weak var postalAreaLabel: UILabel!
    
    
    var fullName: String!
    var email: String!
    var streetAddress: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        zipNumberInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        zipNumberInput.becomeFirstResponder()
        zipNumberInput.delegate = self
    }
    
    func textFieldDidChange(textField: UITextField) {
        if(zipNumberInput.text?.characters.count == 4) {
            getPostalArea()
        }
        else {
            createAccountButton.enabled = false
            postalAreaLabel.enabled = false
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(zipNumberInput.text?.characters.count == 4) {
            self.performSegueWithIdentifier("zipToUsername", sender: self)
            return true
        }
        else {
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "zipToUsername") {
            if let viewController: SignUpUsernameViewController = segue.destinationViewController as? SignUpUsernameViewController {
                viewController.fullName = fullName
                viewController.email = email
                viewController.streetAddress = streetAddress
                viewController.zipNumber = zipNumberInput.text
                viewController.postalArea = postalAreaLabel.text
            }
        }
    }
    
    func getPostalArea() {
        var url = NSURL(string: "https://api.bring.com/shippingguide/api/postalCode.xml?clientUrl=insertYourClientUrlHere&country=no&pnr=" + (zipNumberInput.text)!)
        var xmlParser = NSXMLParser(contentsOfURL: url!)
        xmlParser!.delegate = self
        xmlParser!.parse()
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if(string == "Ugyldig postnummer") {
            postalAreaLabel.enabled = true
            postalAreaLabel.text = "Unknown zip number"
            createAccountButton.enabled = false
        }
        else if(string != "\n  " && string != "\n    \n") {
            createAccountButton.enabled = true
            postalAreaLabel.enabled = true
            postalAreaLabel.text = string
        }
    }
}
