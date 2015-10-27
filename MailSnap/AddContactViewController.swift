//
//  AddContactViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 27/09/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class AddContactViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameHintLabel: UILabel!
    @IBOutlet weak var fullNameHintLabel: UILabel!
    
    @IBOutlet weak var addUsernameLabel: UILabel!
    @IBOutlet weak var addUserSwitch: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    var searchResult: PFUser!
    
    
    var searchActive: Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.stopAnimating()

        usernameLabel.text = PFUser.currentUser()?.username
        fullNameLabel.text = PFUser.currentUser()?["name"] as? String
        
        //searchBar.becomeFirstResponder()
        searchBar.delegate = self
        
        addUserSwitch.setImage(UIImage(named: "delete_friend_icon"), forState: UIControlState.Selected)
        addUserSwitch.setImage(UIImage(named: "add_friend_icon"), forState: UIControlState.Normal)
    }
    
    @IBAction func addUserSwitched(sender: AnyObject) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        addUserSwitch.hidden = true
        addUserSwitch.enabled = false
        if(!addUserSwitch.selected) {
            createFriendship()
        }
        else {
            deleteFriendship()
        }
    }
    
    func deleteFriendship() {
        let friendshipQuery = PFQuery(className: "Friendship")
        friendshipQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        friendshipQuery.whereKey("toUser", equalTo: self.searchResult)
        friendshipQuery.getFirstObjectInBackgroundWithBlock({ (friendship: PFObject?, error: NSError?) -> Void in
            if(error == nil) {
                friendship?.deleteInBackgroundWithBlock({ (succeeded: Bool, error:NSError?) -> Void in
                    if(error == nil) {
                        self.addUserSwitch.selected = false
                        self.addUserSwitch.enabled = true
                        self.addUserSwitch.hidden = false
                        self.activityIndicator.hidden = true
                    }
                    else {
                        self.addUserSwitch.enabled = true
                        self.addUserSwitch.hidden = false
                        self.activityIndicator.hidden = true
                    }
                })
            }
            else {
                // Not friends
                self.addUserSwitch.hidden = false
                self.activityIndicator.stopAnimating()
                self.addUserSwitch.enabled = true
                self.activityIndicator.hidden = true
            }
        })
    }
    
    func createFriendship() {
        let frienship = PFObject(className: "Friendship")
        frienship["fromUser"] = PFUser.currentUser()
        frienship["toUser"] = searchResult
        frienship.saveInBackgroundWithBlock { (suceeded: Bool, error: NSError?) -> Void in
            if(error == nil) {
                self.addUserSwitch.selected = true
                self.addUserSwitch.enabled = true
                self.addUserSwitch.hidden = false
                self.activityIndicator.hidden = true
            }
            else {
                self.addUserSwitch.enabled = true
                self.addUserSwitch.hidden = false
                self.activityIndicator.hidden = true
            }
        }
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        hideOrShow(searchBar)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        hideOrShow(searchBar)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        hideOrShow(searchBar)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        hideOrShow(searchBar)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        hideOrShow(searchBar)
    }
    
    func hideOrShow(searchBar: UISearchBar) {
        if(searchBar.text!.characters.count > 0) {
            hideLabels()
            showAddControls()
        }
        else {
            showLabels()
            hideAddControls()
        }
    }
    
    func hideAddControls() {
        searchResult = nil
        
        addUsernameLabel.hidden = true
        addUserSwitch.hidden = true
        activityIndicator.stopAnimating()
    }
    
    func showAddControls() {
        addUsernameLabel.text = searchBar.text
        addUsernameLabel.hidden = false
        
        if(searchBar.text?.characters.count > 3) {
            beginSearch()
        }
        else {
            addUserSwitch.hidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    func beginSearch() {
        self.searchResult = nil
        activityIndicator.startAnimating()
        addUserSwitch.hidden = true
        
        let userQuery = PFUser.query()
        userQuery?.whereKey("username", equalTo: searchBar.text!.lowercaseString)
        userQuery?.getFirstObjectInBackgroundWithBlock({ (user:PFObject?, error:NSError?) -> Void in
            if(error == nil) {
                self.searchResult = user as! PFUser
                
                let friendshipQuery = PFQuery(className: "Friendship")
                friendshipQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
                friendshipQuery.whereKey("toUser", equalTo: self.searchResult)
                friendshipQuery.getFirstObjectInBackgroundWithBlock({ (friendship: PFObject?, error: NSError?) -> Void in
                    if(error == nil) {
                        // Alreay friends
                        self.addUserSwitch.selected = true
                        self.addUserSwitch.hidden = false
                        self.activityIndicator.stopAnimating()
                    }
                    else {
                        // Not friends
                        self.addUserSwitch.selected = false
                        self.addUserSwitch.hidden = false
                        self.activityIndicator.stopAnimating()
                    }
                })
            }
            else {
                self.activityIndicator.stopAnimating()
                self.addUserSwitch.hidden = true
                self.searchResult = nil
            }
        })
    }
    
    
    func hideLabels() {
        usernameLabel.hidden = true
        usernameHintLabel.hidden = true
        fullNameLabel.hidden = true
        fullNameHintLabel.hidden = true
    }
    
    func showLabels() {
        usernameLabel.hidden = false
        usernameHintLabel.hidden = false
        fullNameLabel.hidden = false
        fullNameHintLabel.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}
