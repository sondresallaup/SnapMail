//
//  ChooseFriendsViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 06/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import LocalAuthentication
import Parse

class FriendsOverviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let tableViewController = UITableViewController()
    
    var searchActive: Bool = false
    var searchResult: [PFUser]!
    var friendships: [PFObject]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResult = []
        friendships = []
        getFriendsFromDB()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableViewController.tableView = self.tableView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("getFriendsFromDB"), forControlEvents: UIControlEvents.ValueChanged)
        tableViewController.refreshControl = refreshControl
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //getFriendsFromDB()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchBar.text?.characters.count > 0) {
            return searchResult.count
        }
        return friendships.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendTableViewCell
        
        
        
        let friendship = friendships[indexPath.row] as PFObject
        let friend = friendship["toUser"] as? PFUser
        if(friend != nil) {
            friend!.fetchIfNeededInBackgroundWithBlock { (friend: PFObject?, error: NSError?) -> Void in
                if(error == nil) {
                    cell.friendLabel.text = friend?.valueForKey("name") as? String
                    cell.friendshipObject = friendship
                    cell.friendObject = friend
                    cell.friendSwitch.selected = true
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    cell.accessoryType = UITableViewCellAccessoryType.DetailButton
                }
                else {
                    
                }
            }
        }
        else {
            let customContact = friendship["customContact"] as? PFObject
            if(customContact != nil) {
                customContact?.fetchIfNeededInBackgroundWithBlock({ (contact: PFObject?, error: NSError?) -> Void in
                    if(error == nil) {
                        cell.friendLabel?.text = contact?.valueForKey("name") as? String
                        cell.friendLabel.textColor = UIColor.orangeColor()
                        cell.friendshipObject = friendship
                        cell.friendSwitch.selected = true
                        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                    }
                    else {
                        
                    }
                })
            }
        }
        
        return cell
    }
    
    func getFriendsFromDB() {
        self.tableViewController.refreshControl?.beginRefreshing()
        friendships = []
        
        let friendshipQuery = PFQuery(className: "Friendship")
        friendshipQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        friendshipQuery.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if(error == nil) {
                self.friendships = results
                self.tableViewController.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
            else {
                
            }
        }
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if(identifier == "showCustomContactDetail") {
            let cell = sender as! UITableViewCell
            if(cell.selectionStyle != UITableViewCellSelectionStyle.None) {
                return true
            }
            else {
                return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showCustomContactDetail") {
            if let viewController: CustomContactDetailViewController = segue.destinationViewController as? CustomContactDetailViewController {
                let friendship = friendships[(self.tableView.indexPathForSelectedRow?.row)!] as PFObject
                let customContact = friendship.objectForKey("customContact") as! PFObject
                viewController.customContact = customContact
            }
        }
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchResult = []
        
        
        if(searchResult.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
            
            
        }
        self.tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(friendships == nil || friendships.count == 0) {
            // Display a message when the table is empty
            let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            messageLabel.text = "No data is currently available. Please pull down to refresh."
            messageLabel.textColor = UIColor.blackColor()
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
            messageLabel.sizeToFit()
            
            self.tableView.backgroundView = messageLabel
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            return 0
        }
        else {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            return 1
        }
    }
    
}
