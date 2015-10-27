//
//  OutboxTableViewController.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 07/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class OutboxTableViewController: UITableViewController {
    
    var postcards: [PFObject]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("getFromDB"), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refreshControl
        
        getFromDB()
    }
    
    override func viewDidAppear(animated: Bool) {
        //getFromDB()
    }
    
    func getFromDB() {
        postcards = []
        self.refreshControl?.beginRefreshing()
        
        let cardsQuery = PFQuery(className: "PostCard")
        cardsQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        cardsQuery.orderByDescending("updatedAt")
        cardsQuery.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if(error == nil) {
                for postcard in results! {
                    self.postcards.append(postcard)
                    self.tableView.reloadData()
                    
                    self.refreshControl?.endRefreshing()
                }
            }
            else {
                // Error message
                self.refreshControl?.endRefreshing()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(postcards.count == 0) {
            self.refreshControl?.endRefreshing()
        }
        
        return postcards.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("outboxCell", forIndexPath: indexPath) as! OutboxTableViewCell
        
        let postcard = postcards[indexPath.row]
        
        let imageFile = postcard.valueForKey("image") as! PFFile
        imageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    cell.imageView?.image = image
                    cell.imageView?.sizeToFit()
                    cell.layoutSubviews()
                    cell.detailsLabel.text = postcard.valueForKey("status") as? String
                    cell.dateLabel.text = self.dateDiff(postcard.createdAt!)

                    cell.recipientLabel.text = postcard.valueForKey("recipientName") as? String
                }
            }
        }
        
        return cell
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(postcards == nil || postcards.count == 0) {
            self.refreshControl?.endRefreshing()
            
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showPostcardDetails") {
            if let viewController: PostcardDetailViewController = segue.destinationViewController as? PostcardDetailViewController {
                let postcard = postcards[(self.tableView.indexPathForSelectedRow?.row)!] as PFObject
                viewController.postcard = postcard
            }
        }
    }
    
    func dateDiff(startDate: NSDate) -> String {
        let f:NSDateFormatter = NSDateFormatter()
        f.timeZone = NSTimeZone.localTimeZone()
        f.dateFormat = "yyyy-M-dd'T'HH:mm:ss.SSSZZZ"
        
        let now = f.stringFromDate(NSDate())
        //let startDate = f.dateFromString(dateStr)
        let endDate = f.dateFromString(now)
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        
        let calendarUnits: NSCalendarUnit = [NSCalendarUnit.WeekOfMonth , NSCalendarUnit.Day , NSCalendarUnit.Hour , NSCalendarUnit.Minute , NSCalendarUnit.Second]
        let dateComponents = calendar.components(calendarUnits, fromDate: startDate, toDate: endDate!, options: NSCalendarOptions.MatchFirst)
        
        let weeks = abs(dateComponents.weekOfMonth)
        let days = abs(dateComponents.day)
        let hours = abs(dateComponents.hour)
        let min = abs(dateComponents.minute)
        let sec = abs(dateComponents.second)
        
        var timeAgo = ""
        
        if (sec > 0){
            timeAgo = "\(sec)s"
        }
        
        if (min > 0){
            timeAgo = "\(min)m"
        }
        
        if(hours > 0){
            timeAgo = "\(hours)h"
        }
        
        if (days > 0) {
            timeAgo = "\(days)d"
        }
        
        if(weeks > 0){
            timeAgo = "\(weeks)w"
        }
        return timeAgo;
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    

}
