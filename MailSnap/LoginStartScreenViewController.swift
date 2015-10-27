//
//  LoginStartScreenViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 26/09/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class LoginStartScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if logged in
        let user = PFUser.currentUser()
        if(user != nil) {
            let currentInstallation = PFInstallation.currentInstallation()
            currentInstallation.setValue(user, forKey: "user")
            currentInstallation.saveInBackground()
            let mainTabBarView = self.storyboard?.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
            self.presentViewController(mainTabBarView, animated: true, completion: nil)
        }
        else {
            let loginView = self.storyboard?.instantiateViewControllerWithIdentifier("LoginStartScreenViewController")
            self.presentViewController(loginView!, animated: true, completion: nil)
        }
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        
    }

}
