//
//  PaymentViewController.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 13/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
    
    var amount: Double!
    
    @IBOutlet weak var cardNumberInput: UITextField!
    @IBOutlet weak var expirationDateInput: UITextField!
    @IBOutlet weak var cvcInput: UITextField!
    @IBOutlet weak var payButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        amount = 50
        
        cardNumberInput.becomeFirstResponder()
        cardNumberInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        expirationDateInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        cvcInput.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func textFieldDidChange(textField: UITextField) {
        if(isInputsOK()) {
            payButton.enabled = true
        }
        else {
            payButton.enabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func onPayClicked(sender: AnyObject) {
        // Initiate the card
        var stripCard = STPCard()
        
        // Split the expiration date to extract Month & Year
        if self.expirationDateInput.text!.isEmpty == false {
            let expirationDate = self.expirationDateInput.text!.componentsSeparatedByString("/")
            let expMonth = UInt(expirationDate[0])
            let expYear = UInt(expirationDate[1])
            
            // Send the card info to Strip to get the token
            stripCard.number = self.cardNumberInput.text
            stripCard.cvc = self.cvcInput.text
            stripCard.expMonth = expMonth!
            stripCard.expYear = expYear!
        }
        
        /*var underlyingError: NSError?
        stripCard.validateCardReturningError(&underlyingError)
        if underlyingError != nil {
            self.spinner.stopAnimating()
            self.handleError(underlyingError!)
            return
        }*/
        
        STPAPIClient.sharedClient().createTokenWithCard(stripCard, completion: { (token, error) -> Void in
            
            if error != nil {
                //self.handleError(error!)
                return
            }
            
            //self.postStripeToken(token!)
        })
    }
    
    func isInputsOK() -> Bool {
        return true
    }

}
