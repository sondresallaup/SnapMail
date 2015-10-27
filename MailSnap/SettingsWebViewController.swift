//
//  SettingsWebViewController.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 09/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit

class SettingsWebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var navigationBarTitle: String!
    var webViewUrl: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSBundle.mainBundle().URLForResource(webViewUrl, withExtension:"html")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
        
        
        //UIWebView.loadRequest(webView)(NSURLRequest(URL: NSURL(string: webViewUrl)!))
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
