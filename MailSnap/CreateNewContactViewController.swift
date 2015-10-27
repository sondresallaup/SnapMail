//
//  CreateNewContactViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 27/09/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class CreateNewContactViewController: UIViewController, NSXMLParserDelegate, UITextFieldDelegate {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var streetAddressTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var postalAreaLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fullNameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        zipTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        fullNameTextField.delegate = self
        streetAddressTextField.delegate = self
        zipTextField.delegate = self
        fullNameTextField.becomeFirstResponder()
    }
    
    func textFieldDidChange(textField: UITextField) {
        if(fullNameTextField.text?.characters.count > 0  && zipTextField.text?.characters.count == 4) {
            getPostalArea()
        }
        else {
            doneButton.enabled = false
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == fullNameTextField && fullNameTextField.text?.characters.count > 0) {
            streetAddressTextField.becomeFirstResponder()
            return true
        }
        else if(textField == streetAddressTextField) {
            zipTextField.becomeFirstResponder()
            return true
        }
        else if(textField == zipTextField && doneButton.enabled == true) {
            onDoneButtonClicked(self)
            return true
        }
        else {
            return false
        }
    }
    

    @IBAction func onCancelClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onDoneButtonClicked(sender: AnyObject) {
        doneButton.enabled = false
        let customContact = PFObject(className: "CustomContact")
        customContact["name"] = fullNameTextField.text
        customContact["street"] = streetAddressTextField.text
        customContact["zip"] = zipTextField.text
        customContact["postalArea"] = postalAreaLabel.text
        customContact.saveInBackgroundWithBlock { (suceeded: Bool, error: NSError?) -> Void in
            if(error == nil) {
                // Save as friends
                let friendship = PFObject(className: "Friendship")
                friendship["fromUser"] = PFUser.currentUser()
                friendship["customContact"] = customContact
                friendship.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                    if(error == nil) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else {
                        // Present error message
                        self.doneButton.enabled = true
                    }
                })
            }
            else {
                // Present error message
                self.doneButton.enabled = true
            }
        }
    }
    
    func getPostalArea() {
        let url = NSURL(string: "https://api.bring.com/shippingguide/api/postalCode.xml?clientUrl=insertYourClientUrlHere&country=no&pnr=" + zipTextField.text!)
        let xmlParser = NSXMLParser(contentsOfURL: url!)
        xmlParser!.delegate = self
        xmlParser!.parse()
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if(string == "Ugyldig postnummer") {
            postalAreaLabel.hidden = false
            postalAreaLabel.text = "Unknown zip number"
            doneButton.enabled = false
        }
        else if(string != "\n  " && string != "\n    \n") {
            postalAreaLabel.hidden = false
            postalAreaLabel.text = string
            doneButton.enabled = true
        }
    }

}
