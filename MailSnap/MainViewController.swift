//
//  MainViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 15/09/15.
//  Copyright (c) 2015 Sondre Sallaup. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let outboxView : OutboxViewController = OutboxViewController(nibName: "OutboxView", bundle: nil)
        let cameraView : CameraViewController = CameraViewController(nibName: "CameraView", bundle: nil)
        let profileView: ProfileViewController = ProfileViewController(nibName: "ProfileView", bundle: nil)
        
        self.addChildViewController(outboxView)
        self.scrollView.addSubview(outboxView.view)
        outboxView.didMoveToParentViewController(self)
        
        self.addChildViewController(cameraView)
        self.scrollView.addSubview(cameraView.view)
        cameraView.didMoveToParentViewController(self)
        
        self.addChildViewController(profileView)
        self.scrollView.addSubview(profileView.view)
        profileView.didMoveToParentViewController(self)
        
        var v2Frame : CGRect = cameraView.view.frame
        v2Frame.origin.x = self.view.frame.width
        cameraView.view.frame = v2Frame
        
        var v3Frame : CGRect = profileView.view.frame
        v3Frame.origin.x = self.view.frame.width * 2
        profileView.view.frame = v3Frame
        
        self.scrollView.contentSize = CGSizeMake(self.view.frame.width * 3, self.view.frame.height)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
