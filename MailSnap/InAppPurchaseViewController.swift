//
//  InAppPurchaseViewController.swift
//  SnapMail
//
//  Created by Sondre Sallaup on 13/10/15.
//  Copyright © 2015 Sondre Sallaup. All rights reserved.
//

import UIKit
import StoreKit

class InAppPurchaseViewController: UIViewController, SKProductsRequestDelegate {
    
    var productIDs: Set<String> = []
    var productsArray: Array<SKProduct!> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        productIDs.insert("snapmail.postcards.5")
        
        requestProductInfo()
    }

    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productRequest = SKProductsRequest(productIdentifiers: productIDs)
            
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("Cannot perform In App Purchases.")
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                productsArray.append(product)
            }
            
            //tblProducts.reloadData()
        }
        else {
            print("There are no products.")
        }
        if response.invalidProductIdentifiers.count != 0 {
            print(response.invalidProductIdentifiers.description)
        }
    }
    

    @IBAction func pay(sender: AnyObject) {
    }
    

}
