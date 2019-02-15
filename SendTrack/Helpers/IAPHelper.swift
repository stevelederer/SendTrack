//
//  IAPHelper.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/14/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import StoreKit
import UIKit

enum IAPHelperAlertType {
    case disabled
    case restored
    case purchased
    
    func message() -> String {
        switch self {
        case .disabled: return "Purchases are disabled on your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully purchased this item"
            
        }
    }
}

class IAPHelper: NSObject {
    static let shared = IAPHelper()
    
    let CONSUMABLE_PURCHASE_PRODUCT_ID = "com.stevelederer.SendTrack.tip1"
    
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    
    var purchaseStatusBlock: ((IAPHelperAlertType) -> Void)?
    
    // MARK: - Make purchase of a product
    
    func canMakePurchase() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchaseMyProduct(index: Int) {
        if iapProducts.count == 0 { return }
        
        if self.canMakePurchase() {
            let product = iapProducts[index]
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
        } else {
            purchaseStatusBlock?(.disabled)
        }
    }
    
    // MARK: - Restore purchase
    
    func restorePurchase() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - Fetch available IAP producs
    
    func fetchAvailableProducts() {
        let productIdentifiers = NSSet(objects: CONSUMABLE_PURCHASE_PRODUCT_ID)
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
}

extension IAPHelper: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    // MARK: - Request IAP Products
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if (response.products.count > 0) {
            iapProducts = response.products
            for product in iapProducts {
                let numberFormatter = NumberFormatter()
                numberFormatter.formatterBehavior = .behavior10_4
                numberFormatter.numberStyle = .currency
                numberFormatter.locale = product.priceLocale
                let price1Str = numberFormatter.string(from: product.price)
                print(product.localizedDescription + "\nfor just \(price1Str!)")
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        purchaseStatusBlock?(.restored)
    }
    
    // MARK: - IAP Payment Queue
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    print("purchased")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.purchased)
                    break
                case .failed:
                    print("failed")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    print("restored")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                default: break
                }
            }
        }
    }
}
