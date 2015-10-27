
//
//  CameraViewController.swift
//  MailSnap
//
//  Created by Sondre Sallaup on 26/09/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var textMessageField: UITextField?
    var backCamera: Bool! = true
    var useFlash: Bool! = false
    var textInputActive: Bool! = false
    var cameraMode: Bool = true
    var blurredImage: UIImage!
    var normalImage: UIImage!
    
    var lastTextLocation: CGPoint!
    var qrCodeFrameView:UIImageView?
    var qrString: String!
    var qrRecipient: String!

    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addedText: UIButton!
    @IBOutlet weak var cancelImageButton: UIButton!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var longPressHintLabel: UILabel!
    @IBOutlet weak var cancelRecipientButton: UIBarButtonItem!
    
    
    
    var imageFile: NSData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: "onFlipCameraClicked:")
        doubleTapGesture.numberOfTapsRequired = 2
        cameraView.addGestureRecognizer(doubleTapGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: "addText:")
        singleTapGesture.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTapGesture)
        
        let textDragGesture = UIPanGestureRecognizer(target: self, action: "moveText:")
        textDragGesture.maximumNumberOfTouches = 1
        textDragGesture.minimumNumberOfTouches = 1
        textInput.addGestureRecognizer(textDragGesture)
        
        let getQRCodeGesture = UILongPressGestureRecognizer(target: self, action: "translateQRCode:")
        //getQRCodeGesture.numberOfTapsRequired = 1
        self.view?.addGestureRecognizer(getQRCodeGesture)
        
        textInput.addTarget(self, action: "addText:", forControlEvents: UIControlEvents.EditingDidBegin)
        textInput.delegate = self
        
        lastTextLocation = textInput.center
        
        
        // Just for testing!
        // 1
        let blurEffect = UIBlurEffect(style: .Dark)
        // 2
        let blurView = UIVisualEffectView(effect: blurEffect)
        // 3
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        initializeQRView()
        
        self.view.addSubview(blurView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        checkSessionToken()
        
        hideAndShowButtons()
        
        checkCamera()
        
        cameraView.contentMode = .ScaleToFill
        previewLayer?.frame = cameraView.bounds
        textInput.center = lastTextLocation
    }
    
    
    @IBAction func shutterButtonClicked(sender: AnyObject) {
        // Setup flash
        if(backCamera == true && useFlash == true) {
            let error : NSError?
            
            let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            if(captureDevice.hasTorch) {
                do {
                    try captureDevice.lockForConfiguration()
                    let torchOn = !captureDevice.torchActive
                    try captureDevice.setTorchModeOnWithLevel(1.0)
                    captureDevice.torchMode = torchOn ? AVCaptureTorchMode.On : AVCaptureTorchMode.Off
                    captureDevice.unlockForConfiguration()
                    
                    NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("takePicture"), userInfo: nil, repeats: false)
                } catch let error1 as NSError {
                    error = error1
                }
                
            }
        }
        else {
            takePicture()
        }
    }
    
    func takePicture() {
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                //UIImageWriteToSavedPhotosAlbum(UIImage(data: imageData)!, nil, nil, nil)
                self.cameraView.hidden = true
                let image = UIImage(data: imageData)
                if(self.backCamera == false) {
                    self.imageView.image = UIImage(CGImage: (image?.CGImage)!, scale: 1.0, orientation: UIImageOrientation.LeftMirrored)
                }
                else {
                    self.imageView.image = image
                }
                self.applyBlurEffect()
                self.normalImage = self.imageView.image
                
                self.imageFile = imageData
                self.cancelImageButton.hidden = false
                self.imageView.hidden = false
                self.shutterButton.hidden = true
                self.nextButton.enabled = true
                self.flipCameraButton.hidden = true
                self.flashButton.hidden = true
                self.saveButton.hidden = false
                self.textButton.hidden = false
                self.libraryButton.hidden = true
                
                self.cameraMode = false
            }
        }
        // Turn off flash
        if(backCamera == true && useFlash == true) {
            let error : NSError?
            
            let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            if(captureDevice.hasTorch) {
                do {
                    try captureDevice.lockForConfiguration()
                    let torchOn = !captureDevice.torchActive
                    try captureDevice.setTorchModeOnWithLevel(1.0)
                    captureDevice.torchMode = torchOn ? AVCaptureTorchMode.On : AVCaptureTorchMode.Off
                    captureDevice.unlockForConfiguration()
                } catch let error1 as NSError {
                    error = error1
                }
                
            }
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
     
        setUpCamera()
    }
    
    func setUpCamera() {
        previewLayer?.removeFromSuperlayer()
        captureSession = AVCaptureSession()
        
        captureSession?.stopRunning()
        
        let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var captureDevice:AVCaptureDevice! = nil
        
        var error : NSError?
        
        if(backCamera == false) {
            for device in videoDevices{
                let device = device as! AVCaptureDevice
                    if device.position == AVCaptureDevicePosition.Front {
                        captureDevice = device
                        break
                    }
            }
        }
        else {
            captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        }
        
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if (error == nil && captureSession?.canAddInput(input) != nil){
            
            captureSession?.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            
            if (captureSession?.canAddOutput(stillImageOutput) != nil){
                captureSession?.addOutput(stillImageOutput)
                
                // QR reader
                let captureMetadataOutput = AVCaptureMetadataOutput()
                if((captureSession?.canAddOutput(captureMetadataOutput)) != nil) {
                    captureSession?.addOutput(captureMetadataOutput)
                    // Set delegate and use the default dispatch queue to execute the call back
                    captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
                    captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
                }
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                //previewLayer?.contentsScale = 10
                cameraView.layer.addSublayer(previewLayer!)
                
                cameraView.contentMode = .ScaleToFill
                previewLayer?.frame = cameraView.bounds
                
                captureSession?.startRunning()
                flipCameraButton.enabled = true
            }
        }
    }
    
    
    
    @IBAction func onEnterTextClicked(sender: AnyObject) {
        let textPopup = UIAlertController(title: "Enter text", message: "Enter your text here.", preferredStyle: UIAlertControllerStyle.Alert)
        
        textPopup.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            self.addedText.setTitle(self.textMessageField?.text, forState: UIControlState.Normal)
        }))
        
        textPopup.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        textPopup.addTextFieldWithConfigurationHandler(addTextField)
        
        presentViewController(textPopup, animated: true, completion: nil)
    }
    
    func addTextField(textField: UITextField!){
        textField.placeholder = "Enter text here"
        textField.text = textMessageField?.text
        self.textMessageField = textField
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "imageTaken") {
            if let viewController: ChooseFriendsViewController = segue.destinationViewController as? ChooseFriendsViewController {
                let imageWithText = textToImage(textInput.text!, inImage: imageView.image!, atPoint: textInput.center)
                viewController.imageFile = UIImageJPEGRepresentation(imageWithText, 1.0)
                if(qrRecipient != nil) {
                    viewController.qrRecipient = qrRecipient
                }
            }
        }
    }
    
    
    @IBAction func onFlipCameraClicked(sender: AnyObject) {
        flipCameraButton.enabled = false
        
        if(backCamera == true) {
            backCamera = false
            flashButton.hidden = true
        }
        else {
            backCamera = true
            flashButton.hidden = false
        }
        
        setUpCamera()
    }
    
    @IBAction func onFlashClicked(sender: AnyObject) {
        if(useFlash == true) {
            useFlash = false
            flashButton.setImage(UIImage(named: "camera_no_flash"), forState: UIControlState.Normal)
        }
        else {
            useFlash = true
            flashButton.setImage(UIImage(named: "camera_with_flash"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func onSaveClicked(sender: AnyObject) {
        let imageToSave = textToImage(textInput.text!, inImage: imageView.image!, atPoint: textInput.center)
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
        saveButton.setTitle("Saved!", forState: UIControlState.Disabled)
        saveButton.enabled = false
    }
    
    
    @IBAction func addText(sender: AnyObject) {
        if(!imageView.hidden) {
            textInputActive = !textInputActive
            
            if(imageView.image != blurredImage) {
                nextButton.enabled = false
                imageView.image = blurredImage
                textInput.hidden = false
                textInput.becomeFirstResponder()
            }
            else {
                nextButton.enabled = true
                imageView.image = normalImage
                textInput.resignFirstResponder()
                if(textInput.text?.characters.count == 0) {
                    textInput.hidden = true
                }
            }
        }
        else {
            if(qrString != nil) {
                view.bringSubviewToFront(longPressHintLabel!)
                longPressHintLabel.hidden = false
                delay(1.0) {
                    self.longPressHintLabel.hidden = true
                }
            }
        }
    }
    
    func moveText(sender: UIPanGestureRecognizer) {
        let location = sender.translationInView(self.view)
        textInput.frame.origin.x = textInput.frame.origin.x + location.x
        textInput.frame.origin.y = textInput.frame.origin.y + location.y
        
        textInput.center = CGPointMake(lastTextLocation.x + location.x - 0, lastTextLocation.y + location.y + 0)
        
        if(sender.state == UIGestureRecognizerState.Ended) {
            lastTextLocation = textInput.center
        }
        saveButton.enabled = true
    }
    
    @IBAction func onCancelClicked(sender: AnyObject) {
        cameraMode = true
        
        textInput.resignFirstResponder()
        cancelImageButton.hidden = true
        imageView.hidden = true
        cameraView.hidden = false
        shutterButton.hidden = false
        nextButton.enabled = false
        self.flipCameraButton.hidden = false
        flashButton.hidden = false
        self.saveButton.hidden = true
        textButton.hidden = true
        textInput.hidden = true
        textInputActive = false
        textInput.text = ""
        libraryButton.hidden = false
    }
    
    func hideAndShowButtons() {
        if(cameraMode) {
            if(backCamera == true) {
                flashButton.hidden = false
            }
            else {
                flashButton.hidden = true
            }
            
            cancelImageButton.hidden = true
            imageView.hidden = true
            cameraView.hidden = false
            shutterButton.hidden = false
            nextButton.enabled = false
            flipCameraButton.hidden = false
            flashButton.hidden = false
            saveButton.hidden = true
            textButton.hidden = true
            textInput.hidden = true
            textInputActive = false
            libraryButton.hidden = false
        }
        else {
            cancelImageButton.hidden = false
            imageView.hidden = false
            cameraView.hidden = true
            shutterButton.hidden = true
            nextButton.enabled = true
            flipCameraButton.hidden = true
            flashButton.hidden = true
            saveButton.hidden = false
            textButton.hidden = false
            textInput.hidden = false
            libraryButton.hidden = true
        }
    }
    
    func changeCameraMode() {
        cameraMode = !cameraMode
        
        cancelImageButton.hidden = !cancelImageButton.hidden
        imageView.hidden = !imageView.hidden
        cameraView.hidden = !cameraView.hidden
        shutterButton.hidden = !shutterButton.hidden
        nextButton.enabled = !nextButton.enabled
        flipCameraButton.hidden = !flipCameraButton.hidden
        flashButton.hidden = !flashButton.hidden
        saveButton.hidden = !saveButton.hidden
        textButton.hidden = !textButton.hidden
        textInput.hidden = !textInput.hidden
        libraryButton.hidden = !libraryButton.hidden
    }
    
    func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.whiteColor()
        let textFont: UIFont = UIFont(name: "Helvetica Bold", size: 100)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
        ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        let widthDiff = (inImage.size.width - 450) / self.view.frame.width
        let heighDiff = (inImage.size.height - 50) / self.view.frame.height
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRectMake(atPoint.x * widthDiff, atPoint.y * heighDiff, inImage.size.width, inImage.size.height)
        
        //Now Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        addText(self)
        
        return true
    }
    
    func applyBlurEffect(){
        let imageToBlur = CIImage(image: imageView.image!)
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        blurfilter!.setValue(25, forKey: kCIInputRadiusKey)
        blurfilter!.setValue(imageToBlur, forKey: "inputImage")
        let resultImage = blurfilter!.valueForKey("outputImage") as! CIImage
        var blurredImage = UIImage(CIImage: resultImage)
        let cropped:CIImage=resultImage.imageByCroppingToRect(CGRectMake(0, 0,imageToBlur!.extent.size.width, imageToBlur!.extent.size.height))
        blurredImage = UIImage(CIImage: cropped)
        self.blurredImage = blurredImage
    }
    
    @IBAction func onLibraryButtonClicked(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        //imagePicker.mediaTypes = [kUTTypeImage as NSString]
        imagePicker.navigationBar.barTintColor = UIColor.grayColor()
        imagePicker.navigationBar.tintColor = UIColor.whiteColor()
        imagePicker.allowsEditing = true
        
        self.presentViewController(imagePicker, animated: true,
            completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.imageView.image = image
        self.applyBlurEffect()
        self.normalImage = self.imageView.image
        
        //self.imageFile = imageData
        self.cancelImageButton.hidden = false
        self.imageView.hidden = false
        self.shutterButton.hidden = true
        self.nextButton.enabled = true
        self.flipCameraButton.hidden = true
        self.flashButton.hidden = true
        self.saveButton.hidden = false
        self.textButton.hidden = false
        self.libraryButton.hidden = true
        
        self.cameraMode = false
        
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRectZero
            self.qrString = nil
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = previewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            if metadataObj.stringValue != nil {
                self.qrString = metadataObj.stringValue
            }
        }
    }
    
    func translateQRCode(sender: AnyObject) {
        if(qrString != nil) {
            let qrStringArr = qrString.characters.split{$0 == ":"}.map(String.init)
            let qrKey = qrStringArr[0]
            let qrValue = qrStringArr[1]
            if(qrKey == "recipient") {
                findUserByUserId(qrValue)
            }
            else if(qrKey == "redeemCode") {
                // Redeem shit here
                redeemCode(qrValue)
            }
        }
    }
    
    func findUserByUserId(userId: String) {
        let recipientQuery = PFUser.query()
        recipientQuery?.getObjectInBackgroundWithId(userId, block: { (recipient: PFObject?, error: NSError?) -> Void in
            if(recipient != nil) {
                self.cancelRecipientButton.enabled = true
                self.qrRecipient = userId
                self.title = recipient?.valueForKey("name") as? String
                //TODO: check if friends and ask to add friend if not
                self.checkIfFriends(recipient as! PFUser)
            }
            else {
                self.cancelRecipientButton.enabled = false
                self.title = "Camera"
                self.longPressHintLabel.text = "Cannot find user 😭"
                self.view.bringSubviewToFront(self.longPressHintLabel!)
                self.longPressHintLabel.hidden = false
                self.delay(1.5, closure: {
                    self.longPressHintLabel.hidden = true
                    self.longPressHintLabel.text = "Long press 👆"
                })
            }
        })
    }
    
    func checkIfFriends(recipient: PFUser) {
        let friendshipQuery = PFQuery(className: "Friendship")
        friendshipQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        friendshipQuery.whereKey("toUser", equalTo: recipient)
        friendshipQuery.getFirstObjectInBackgroundWithBlock { (friendship: PFObject?, error: NSError?) -> Void in
            if(error == nil) {
                // They are friends
            }
            else if(error?.code == 101){
                // They are not friends, ask to befriend
                let alert = UIAlertController(title: "Add friend?", message: "Do you want to add " + self.title! + " as friend?", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (action) -> Void in
                    self.cancelRecipient(self)
                }))
                alert.addAction(UIAlertAction(title: "Yes!", style: .Default, handler: { (action) -> Void in
                    let newFriendship = PFObject(className: "Friendship")
                    newFriendship["fromUser"] = PFUser.currentUser()
                    newFriendship["toUser"] = recipient
                    newFriendship.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                        if(error == nil) {
                            //Added
                        }
                        else {
                            // Error message
                        }
                    })
                }))
                
                // 4. Present the alert.
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    func redeemCode(redeemCode: String) {
        // Try to find code from DB
        let redeemQuery = PFQuery(className: "RedeemCodes")
        redeemQuery.whereKey("code", equalTo: redeemCode)
        redeemQuery.getFirstObjectInBackgroundWithBlock { (redeemObject: PFObject?, error: NSError?) -> Void in
            if(error == nil) {
                if(redeemObject?.objectForKey("used") as! Bool) {
                    var alert = UIAlertController()
                    alert.title = "Code is used"
                    alert.message = "This redeem code has already been used"
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in}))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else {
                    // Set as used
                    redeemObject?.setValue(true, forKey: "used")
                    redeemObject?.setValue(PFUser.currentUser(), forKey: "user")
                    redeemObject?.saveInBackgroundWithBlock({ (suceeded: Bool, error: NSError?) -> Void in
                        if(error == nil) {
                            // Save amout to user's wallet
                            let amount = redeemObject?.valueForKey("amount") as! Double
                            if(amount > 0) {
                                let currentUser = PFUser.currentUser()
                                currentUser?.fetchInBackgroundWithBlock({ (currentUser: PFObject?, error: NSError?) -> Void in
                                    if(error == nil) {
                                        let userWallet = currentUser!.valueForKey("wallet") as! Double
                                        currentUser!.setValue(userWallet + amount, forKey: "wallet")
                                        currentUser!.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError?) -> Void in
                                            if(error == nil) {
                                                var alert = UIAlertController()
                                                alert.title = "Success!"
                                                alert.message = String(amount) + " 💵 has been added to your wallet!"
                                                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in}))
                                                self.presentViewController(alert, animated: true, completion: nil)
                                            }
                                            else {
                                                var alert = UIAlertController()
                                                alert.title = "Error"
                                                alert.message = "An error has occured"
                                                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in}))
                                                self.presentViewController(alert, animated: true, completion: nil)
                                            }
                                        })
                                    }
                                })
                            }
                        }
                        else {
                            var alert = UIAlertController()
                            alert.title = "Error"
                            alert.message = "An error has occured"
                            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in}))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    })
                }
            }
            else if(error?.code == 101) {
                // Code is false
                var alert = UIAlertController()
                alert.title = "Error"
                alert.message = "Redeem code doesn't exist"
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in}))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                var alert = UIAlertController()
                alert.title = "Error"
                alert.message = "An error has occured"
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in}))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func cancelRecipient(sender: AnyObject) {
        self.cancelRecipientButton.enabled = false
        
        self.title = "Camera"
        self.qrRecipient = nil
        self.qrString = nil
    }
    
    
    func initializeQRView() {
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIImageView(image: UIImage(named: "erna"))
        qrCodeFrameView?.frame = CGRectZero
        
        //qrCodeFrameView?.layer.borderColor = UIColor.orangeColor().CGColor
        //qrCodeFrameView?.layer.borderWidth = 9
        
        view.addSubview(qrCodeFrameView!)
        view.bringSubviewToFront(qrCodeFrameView!)
    }
    
    func checkCamera() {
        let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authStatus {
        case AVAuthorizationStatus.Authorized: break // Do you stuffer here i.e. allowScanning()
        case AVAuthorizationStatus.Denied: alertToEncourageCameraAccessInitially()
        case AVAuthorizationStatus.NotDetermined: alertPromptToAllowCameraAccessViaSetting()
        default: alertToEncourageCameraAccessInitially()
        }
        
    }
    
    func alertToEncourageCameraAccessInitially() {
        let alert = UIAlertController(title: "Use your camera?", message: "Using SnapMail requires access to your camera.", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .Cancel, handler: { (alert) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        
        let alert = UIAlertController(title: "Use your camera?", message: "Using SnapMail requires access to your camera.", preferredStyle: UIAlertControllerStyle.Alert)
        
        /*alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel) { alert in
            if AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 0 {
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.checkCamera() } }
            }
            })*/
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func checkSessionToken() {
        let testSessionQuery = PFQuery(className: "Friendhsip");
        testSessionQuery.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        testSessionQuery.getFirstObjectInBackgroundWithBlock { (testObject: PFObject?, error: NSError?) -> Void in
            if(error != nil) {
                if(error?.code == PFErrorCode.ErrorInvalidSessionToken.rawValue) {
                    // Session token is invalid. User has to login again
                    let alert = UIAlertController(title: "Session expired", message: "Your session has expired. Please login again", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (alert) -> Void in }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    let loginView = self.storyboard?.instantiateViewControllerWithIdentifier("LoginStartScreenViewController")
                    self.presentViewController(loginView!, animated: true, completion: nil)
                    PFUser.logOut()
                }
            }
        }
    }

}
