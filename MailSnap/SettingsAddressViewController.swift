//
//  SettingsAddressViewController.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 09/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class SettingsAddressViewController: UIViewController, NSXMLParserDelegate {

    @IBOutlet weak var addressInput: UITextField!
    @IBOutlet weak var zipInput: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var postalAreaLabel: UILabel!
    
    
    var currentUser = PFUser()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = PFUser.currentUser()!
        
        addressInput.text = currentUser.valueForKey("street") as? String
        zipInput.text = currentUser.valueForKey("zip") as? String
        
        addressInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        zipInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if((addressInput.text?.characters.count)! > 0 && addressInput.text != currentUser.valueForKey("street") as? String && zipInput.text?.characters.count == 4) {
            getPostalArea()
            postalAreaLabel.hidden = false
        }
        else if((zipInput.text?.characters.count)! == 4 && zipInput.text != currentUser.valueForKey("zip") as? String && addressInput.text?.characters.count > 0) {
            getPostalArea()
            postalAreaLabel.hidden = false
        }
        else {
            postalAreaLabel.enabled = false
            saveButton.hidden = true
        }
    }
    

    @IBAction func save(sender: AnyObject) {
        saveButton.enabled = false
        saveButton.titleLabel?.text = "SAVING..."
        
        currentUser["street"] = addressInput.text
        currentUser["zip"] = zipInput.text
        currentUser["postalArea"] = postalAreaLabel.text
        currentUser.saveInBackgroundWithBlock { (suceeded: Bool, error: NSError?) -> Void in
            if(error == nil) {
                self.navigationController?.popViewControllerAnimated(true)
            }
            else {
                self.saveButton.enabled = true
                self.saveButton.titleLabel?.text = "SAVE"
            }
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
            saveButton.hidden = true
        }
        else if(string != "\n  " && string != "\n    \n") {
            postalAreaLabel.hidden = false
            postalAreaLabel.text = string
            saveButton.hidden = false
        }
    }
    

}
