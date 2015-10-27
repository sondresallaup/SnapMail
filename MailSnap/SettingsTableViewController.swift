//
//  SettingsTableViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 26/09/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import LocalAuthentication
import Parse


class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var walletLabel: UILabel!
    @IBOutlet weak var touchIdSwitch: UISwitch!
    @IBOutlet weak var touchIdCell: UITableViewCell!
    
    
    let currentUser = PFUser.currentUser()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fullNameLabel.text = currentUser?.valueForKey("name") as? String
        usernameLabel.text = currentUser?.username
        emailLabel.text = currentUser?.email
        addressLabel.text = currentUser?.valueForKey("street") as? String
        
        let wallet = currentUser?.valueForKey("wallet") as! Int
        walletLabel.text = String(wallet) + " 💵"
        
        if(isUserUsingTouchID()) {
            touchIdSwitch.on = true
        }
        else {
            touchIdSwitch.on = false
        }
        
        if(!isSupportingTouchID()) {
            touchIdCell.hidden = true
        }
    }
    
    @IBAction func touchIdSwitchDidChange(sender: AnyObject) {
        touchIdSwitch.enabled = false
        if(touchIdSwitch.on) {
            // Enter password
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Password", message: "Enter your password", preferredStyle: .Alert)
            
            //2. Add the text field. You can configure it however you need.
            alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
                textField.secureTextEntry = true
                textField.keyboardType = UIKeyboardType.NumberPad
            })
            
            //3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                let passwordTextField = alert.textFields![0] 
                
                PFUser.logInWithUsernameInBackground(PFUser.currentUser()!.username!, password: passwordTextField.text!) { (user: PFUser?, error: NSError?) -> Void in
                    if(error == nil) {
                        let currentInstallation = PFInstallation.currentInstallation()
                        currentInstallation.setObject(true, forKey: "useTouchID")
                        currentInstallation.saveInBackground()
                        self.touchIdSwitch.enabled = true
                    }
                    else {
                        self.touchIdSwitch.on = false
                        self.touchIdSwitch.enabled = true
                        let alert = UIAlertView()
                        alert.title = "Error"
                        alert.message = "Wrong password!"
                        alert.addButtonWithTitle("Got it")
                        alert.show()
                    }
                }
            }))
            
            //3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                self.touchIdSwitch.on = false
                self.touchIdSwitch.enabled = true
            }))
            
            // 4. Present the alert.
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.touchIdSwitch.enabled = true
            let currentInstallation = PFInstallation.currentInstallation()
            currentInstallation.setObject(false, forKey: "useTouchID")
            currentInstallation.saveInBackground()
        }
    }
    
    func isUserUsingTouchID() -> Bool {
        let currentInstallation = PFInstallation.currentInstallation()
        let useTouchID = currentInstallation.objectForKey("useTouchID") as? Bool
        if(useTouchID != nil) {
            return useTouchID == true
        }
        return false
    }
    
    func isSupportingTouchID() -> Bool {
        
        return true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 3 && indexPath.row == 0) {
            logOut()
        }
    }
    
    func logOut() {
        PFUser.logOut()
        
        let loginStartView = self.storyboard?.instantiateViewControllerWithIdentifier("LoginStartScreenViewController")
        self.presentViewController(loginStartView!, animated: true, completion: nil)
    }
    
    //Support webviews
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var titleString: String!
        var url: String = "support/"
        
        if(segue.identifier == "showSupport") {
            titleString = "Support"
            url += "support"
        }
        else if(segue.identifier == "showPrivacy") {
            titleString = "Privacy Policy"
            url += "privacy"
        }
        else if(segue.identifier == "showTerms") {
            titleString = "Terms of Use"
            url += "terms"
        }
        else if(segue.identifier == "showLicenses") {
            titleString = "Licenses"
            url += "licenses"
        }
        
        if let viewController: SettingsWebViewController = segue.destinationViewController as? SettingsWebViewController {
            viewController.webViewUrl = url
            viewController.title = titleString
        }
    }

}
