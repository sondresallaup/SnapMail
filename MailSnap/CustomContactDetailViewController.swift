//
//  CustomContactDetailViewController.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 25/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class CustomContactDetailViewController: UIViewController, NSXMLParserDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var fullNameInput: UITextField!
    @IBOutlet weak var streetInput: UITextField!
    @IBOutlet weak var zipInput: UITextField!
    @IBOutlet weak var postalAreaLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    var customContact: PFObject!
    var textFieldChanged: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        customContact.fetchInBackgroundWithBlock { (customContact: PFObject?, error: NSError?) -> Void in
            if(error == nil) {
                self.fullNameInput.text = customContact?.valueForKey("name") as? String
                self.title = customContact?.valueForKey("name") as? String
                self.streetInput.text = customContact?.valueForKey("street") as? String
                self.zipInput.text = customContact?.valueForKey("zip") as? String
                self.getPostalArea()
            }
            else {
                // Show error message
            }
        }
        
        fullNameInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        streetInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        zipInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        fullNameInput.delegate = self
        streetInput.delegate = self
        zipInput.delegate = self
    }
    
    @IBAction func save(sender: AnyObject) {
        saveButton.enabled = false
        customContact.setValue(fullNameInput.text, forKey: "name")
        customContact.setValue(streetInput.text, forKey: "street")
        customContact.setValue(zipInput.text, forKey: "zip")
        customContact.setValue(postalAreaLabel.text, forKey: "postalArea")
        customContact.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
            if(error == nil) {
                self.textFieldChanged = false
                self.navigationController?.popViewControllerAnimated(true)
            }
            else {
                // Show error message
                self.saveButton.enabled = true
            }
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        textFieldChanged = true
        
        self.title = fullNameInput.text
        if(zipInput.text?.characters.count == 4) {
            getPostalArea()
        }
        else {
            saveButton.enabled = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == fullNameInput && fullNameInput.text?.characters.count > 0) {
            streetInput.becomeFirstResponder()
            return true
        }
        else if(textField == streetInput) {
            zipInput.becomeFirstResponder()
            return true
        }
        else if(textField == zipInput && saveButton.enabled == true) {
            save(self)
            return true
        }
        else {
            return false
        }
    }
    
    func getPostalArea() {
        let url = NSURL(string: "https://api.bring.com/shippingguide/api/postalCode.xml?clientUrl=insertYourClientUrlHere&country=no&pnr=" + zipInput.text!)
        let xmlParser = NSXMLParser(contentsOfURL: url!)
        xmlParser!.delegate = self
        xmlParser!.parse()
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if(string == "Ugyldig postnummer") {
            postalAreaLabel.hidden = false
            postalAreaLabel.text = "Unknown zip number"
            //doneButton.enabled = false
        }
        else if(string != "\n  " && string != "\n    \n") {
            postalAreaLabel.hidden = false
            postalAreaLabel.text = string
            
            if(fullNameInput.text?.characters.count > 0  && zipInput.text?.characters.count == 4) {
                saveButton.enabled = true
            }
            else {
                saveButton.enabled = false
            }
        }
    }
}
