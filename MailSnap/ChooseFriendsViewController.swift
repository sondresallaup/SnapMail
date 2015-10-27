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

class ChooseFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    
    let tableViewController = UITableViewController()
    
    var imageFile: NSData!
    
    var searchActive: Bool = false
    var searchResult: [PFUser]!
    var friendships: [PFObject]!
    var selectedFriends: [PFObject]!
    var selectedNames: [String]!
    var qrRecipient: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        searchResult = []
        friendships = []
        selectedFriends = []
        selectedNames = []
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
        
        getFriendsFromDB()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchBar.text?.characters.count > 0) {
            return searchResult.count
        }
        return friendships.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! ChooseFriendTableViewCell
        
        
        
        let friendship = friendships[indexPath.row] as PFObject
        let friend = friendship["toUser"] as? PFUser
        if(friend != nil) {
            friend!.fetchIfNeededInBackgroundWithBlock { (friend: PFObject?, error: NSError?) -> Void in
                if(error == nil) {
                    cell.textLabel?.text = friend?.valueForKey("name") as? String
                    if(self.qrRecipient != nil) {
                        if(friend!.objectId == self.qrRecipient && friend?.objectId != nil) {
                            // Select cell
                            self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                            self.nextButton.enabled = true
                            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                            if(!self.selectedFriends.contains(friendship)) {
                                self.selectedFriends.append(friendship)
                            }
                            if(!self.selectedNames.contains((friend?.valueForKey("name") as? String)!)) {
                                self.selectedNames.append((friend?.valueForKey("name") as? String)!)
                            }
                        }
                    }
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
                        cell.textLabel?.text = contact?.valueForKey("name") as? String
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if(tableView.indexPathsForSelectedRows?.count > 0) {
            nextButton.enabled = true
        }
        else {
            nextButton.enabled = false
        }
        let selectedFriendship = friendships[indexPath.row]
        selectedFriends.append(selectedFriendship)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        selectedNames.append((cell?.textLabel?.text)!)
        
        if (cell!.selected) {
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            cell!.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath)
    {
        if(tableView.indexPathsForSelectedRows?.count > 0) {
            nextButton.enabled = true
        }
        else {
            nextButton.enabled = false
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if (cell!.selected) {
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else {
            cell!.accessoryType = UITableViewCellAccessoryType.None
            let selectedFriendship = friendships[indexPath.row]
            if(selectedFriends.contains(selectedFriendship)) {
                selectedNames.removeAtIndex(selectedFriends.indexOf(selectedFriendship)!)
                selectedFriends.removeAtIndex(selectedFriends.indexOf(selectedFriendship)!)
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


    @IBAction func onSendClicked(sender: AnyObject) {
        if(isUserUsingTouchID()) {
            payWithTouchID()
        }
        else {
            payWithoutTouchID()
        }
    }
    
    func payWithTouchID() {
        // Get the local authentication context.
        let context = LAContext()
        
        // Declare a NSError variable.
        var error: NSError?
        
        // Set the reason string that will appear on the authentication alert.
        let reasonString = "Pay " + String(getMailingFee()) + " 💵"
        
        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                
                if success {
                    self.pay()
                }
                else{
                    // If authentication failed then show a message to the console with a short description.
                    // In case that the error is a user fallback, then show the password alert view.
                    print(evalPolicyError?.localizedDescription)
                    
                    switch evalPolicyError!.code {
                        
                    case LAError.SystemCancel.rawValue:
                        self.payWithoutTouchID()
                        
                    case LAError.UserCancel.rawValue:
                        self.payWithoutTouchID()
                        
                    case LAError.UserFallback.rawValue:
                        print("User selected to enter custom password")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.payWithoutTouchID()
                        })
                        
                    default:
                        print("Authentication failed")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.payWithoutTouchID()
                        })
                    }
                }
                
            })]
        }
    }
    
    func payWithoutTouchID() {
        // Enter password
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Pay " + String(getMailingFee()) + " 💵", message: "Enter your password", preferredStyle: .Alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.secureTextEntry = true
            textField.keyboardType = UIKeyboardType.NumberPad
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in }))
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let passwordTextField = alert.textFields![0]
            
            PFUser.logInWithUsernameInBackground(PFUser.currentUser()!.username!, password: passwordTextField.text!) { (user: PFUser?, error: NSError?) -> Void in
                if(error == nil) {
                    self.pay()
                }
                else {
                    let alert = UIAlertView()
                    alert.title = "Error"
                    alert.message = "Wrong password!"
                    alert.addButtonWithTitle("Got it")
                    alert.show()
                }
            }
        }))
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func pay() {
        let currentUser = PFUser.currentUser()
        currentUser?.fetchInBackgroundWithBlock({ (user: PFObject?, error: NSError?) -> Void in
            if(error == nil) {
                let wallet = user?.objectForKey("wallet") as! Int
                
                if(wallet >= self.getMailingFee()) {
                    // Has enough money
                    
                    currentUser?.setValue(wallet - self.getMailingFee(), forKey: "wallet")
                    currentUser?.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                        if(error == nil) {
                            self.sendPostCards()
                        }
                        else {
                            // Error message
                        }
                    })
                }
                else {
                    // Open wallet
                    let alert = UIAlertView()
                    alert.title = "Not enough money"
                    alert.message = "Please fill your wallet"
                    alert.addButtonWithTitle("Got it")
                    alert.show()
                }
            }
            else {
                // Error message
            }
        })
    }
    
    func sendPostCards() {
        // Send image
        for var i = 0; i < selectedFriends.count; i++ {
            
            let postCard = PFObject(className: "PostCard")
            postCard["fromUser"] = PFUser.currentUser()
            var recipient = selectedFriends[i].valueForKey("toUser") as? PFObject
            if(recipient == nil) {
                recipient = selectedFriends[i].valueForKey("customContact") as! PFObject
                postCard["recipientCustom"] = recipient
            }
            else {
                postCard["recipientUser"] = recipient
            }
            postCard["recipientName"] = selectedNames[i]
            
            let pfImageFile = PFFile(name: "postcard.jpeg", data: imageFile)
            postCard["image"] = pfImageFile
            postCard["status"] = "NOT_SENT"
            postCard.saveInBackground() // Note to self: add a target
        }
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func isUserUsingTouchID() -> Bool {
        let currentInstallation = PFInstallation.currentInstallation()
        let useTouchID = currentInstallation.objectForKey("useTouchID") as? Bool
        if(useTouchID != nil) {
            return useTouchID == true
        }
        return false
    }
    
    func getMailingFee() -> Int {
        
        return selectedFriends.count * 1
    }

}
