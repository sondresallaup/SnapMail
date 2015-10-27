//
//  FriendTableViewCell.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 20/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var friendLabel: UILabel!
    @IBOutlet weak var friendSwitch: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var friendshipObject: PFObject!
    var friendObject: PFObject!
    
    
    @IBAction func onSwitch(sender: AnyObject) {
        if(friendshipObject != nil) {
            friendSwitch.hidden = true
            activityIndicator.startAnimating()
            activityIndicator.hidden = false
            if(friendSwitch.selected) {
                // Delete friendship
                friendshipObject.deleteInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                    self.friendSwitch.enabled = true
                    if(error == nil) {
                        self.friendSwitch.selected = false
                        self.friendSwitch.hidden = false
                        self.activityIndicator.hidden = true
                    }
                    else {
                        // Maybe an error message?
                        self.friendSwitch.hidden = false
                        self.activityIndicator.hidden = true
                    }
                })
            }
            else {
                // Create friendship
                let newFriendsip = PFObject(className: "Friendship")
                newFriendsip["fromUser"] = PFUser.currentUser()
                newFriendsip["toUser"] = friendObject
                newFriendsip.saveInBackgroundWithBlock({ (suceeded: Bool, error: NSError?) -> Void in
                    self.friendSwitch.enabled = true
                    if(error == nil) {
                        self.friendSwitch.selected = true
                        self.friendSwitch.hidden = false
                        self.activityIndicator.hidden = true
                    }
                    else {
                        // Maybe an error message?
                        self.friendSwitch.hidden = false
                        self.activityIndicator.hidden = true
                    }
                })
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        friendSwitch.setImage(UIImage(named: "delete_friend_icon"), forState: UIControlState.Selected)
        friendSwitch.setImage(UIImage(named: "add_friend_icon"), forState: UIControlState.Normal)
        friendSwitch.selected = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
