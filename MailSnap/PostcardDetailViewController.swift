//
//  PostcardDetailViewController.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 16/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import Parse

class PostcardDetailViewController: UIViewController, NSXMLParserDelegate {
    
    var postcard: PFObject!
    var normalImage: UIImage!
    var blurredImage: UIImage!
    var isDetailsShowing: Bool = false
    var isShowingBack: Bool = false
    var currentUser: PFUser!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var postcardInformationLabel: UILabel!
    @IBOutlet weak var cardBackView: UIView!
    @IBOutlet weak var addressToLabel: UILabel!
    @IBOutlet weak var addressFromLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentUser = PFUser.currentUser()
        getPostalArea()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        self.title = postcard.valueForKey("recipientName") as! String
        addressToLabel.text = (postcard.valueForKey("recipientName") as! String).uppercaseString + "\n(POSTAL ADDRESS HIDDEN)"
        let imageFile = postcard.valueForKey("image") as! PFFile
        imageFile.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    let image = UIImage(data:imageData)
                    self.imageView?.image = image
                    self.normalImage = image
                    self.applyBlurEffect()
                }
            }
        }
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: "showDetails:")
        singleTapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTapGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: "swipeCardRight:")
        swipeRightGesture.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeRightGesture)
        
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: "swipeCardLeft:")
        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeftGesture)
    }
    
    func showDetails(sender: AnyObject) {
        if(!isShowingBack) {
            isDetailsShowing = !isDetailsShowing
            
            if(isDetailsShowing) {
                postcardInformationLabel.hidden = false
                imageView.image = blurredImage
            }
            else {
                postcardInformationLabel.hidden = true
                imageView.image = normalImage
            }
        }
    }

    func swipeCardRight(sender: AnyObject) {
        if(isShowingBack) {
            //imageView = UIImageView(image: normalImage)
            UIView.transitionFromView(cardBackView, toView: imageView, duration: 1, options: [UIViewAnimationOptions.TransitionFlipFromLeft, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
        }
        else {
            UIView.transitionFromView(imageView, toView: cardBackView, duration: 1, options: [UIViewAnimationOptions.TransitionFlipFromLeft, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
        }
        isShowingBack = !isShowingBack
    }
    
    func swipeCardLeft(sender: AnyObject) {
        if(isShowingBack) {
            //imageView = UIImageView(image: normalImage)
            UIView.transitionFromView(cardBackView, toView: imageView, duration: 1, options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
        }
        else {
            UIView.transitionFromView(imageView, toView: cardBackView, duration: 1, options: [UIViewAnimationOptions.TransitionFlipFromRight, UIViewAnimationOptions.ShowHideTransitionViews], completion: nil)
        }
        isShowingBack = !isShowingBack
    }
    

    func applyBlurEffect(){
        let imageToBlur = CIImage(image: imageView.image!)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(25, forKey: kCIInputRadiusKey)
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter!.valueForKey("outputImage") as! CIImage
        let blurredImage = UIImage(CIImage: resultImage)
        //let cropped:CIImage=resultImage.imageByCroppingToRect(CGRectMake(0, 0,imageToBlur!.extent.size.width, imageToBlur!.extent.size.height))
        //blurredImage = UIImage(CIImage: cropped)
        self.blurredImage = blurredImage
    }
    
    func getPostalArea() {
        let url = NSURL(string: "https://api.bring.com/shippingguide/api/postalCode.xml?clientUrl=insertYourClientUrlHere&country=no&pnr=" + (currentUser?.valueForKey("zip") as! String))
        let xmlParser = NSXMLParser(contentsOfURL: url!)
        xmlParser!.delegate = self
        xmlParser!.parse()
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if(string == "\n  " || string == "\n    \n") {
        }
        else {
            var fromAddressText = currentUser?.valueForKey("name") as! String
            fromAddressText += "\n" + (currentUser?.valueForKey("street") as! String)
            fromAddressText += "\n" + (currentUser?.valueForKey("zip") as! String)
            if(string != "Ugyldig postnummer") {
                fromAddressText += " " + string
            }
            addressFromLabel.text = fromAddressText.uppercaseString
        }
    }

}
