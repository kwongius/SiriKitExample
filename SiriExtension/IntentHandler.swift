//
//  IntentHandler.swift
//  SiriExtension
//
//  Created by Kevin Wong on 6/17/16.
//  Copyright © 2016 Pixio. All rights reserved.
//

import Intents
import PixioWalletCore



class IntentHandler: INExtension, INSendPaymentIntentHandling, INRequestPaymentIntentHandling {
    
    override func handler(for intent: INIntent) -> AnyObject {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }

    
    
    // MARK: - INSendPaymentIntentHandling methods
    
    func resolvePayee(forSendPayment intent: INSendPaymentIntent, with completion: (INPersonResolutionResult) -> Swift.Void) {
        
        guard let payee = intent.payee else {
            completion(INPersonResolutionResult.needsValue())
            return
        }
        
        
        let resolutionResult: INPersonResolutionResult
        
        if let _ = Wallet.walletAddress(forUser: payee.displayName) {
            resolutionResult = INPersonResolutionResult.success(with: payee)
        }
        else {
            resolutionResult = INPersonResolutionResult.needsMoreDetails(for: payee)
        }
        
        completion(resolutionResult)
    }
    
    
    func resolveCurrencyAmount(forSendPayment intent: INSendPaymentIntent, with completion: (INCurrencyAmountResolutionResult) -> Swift.Void) {
        let resolutionResult: INCurrencyAmountResolutionResult
        
        if let amount = intent.currencyAmount {
            if let bitcoinAmount = amount.amount.convertToBitcoin(from: amount.currencyCode) where Wallet.canSpend(bitcoinAmount) {
                resolutionResult = INCurrencyAmountResolutionResult.success(with: amount)
            }
            else {
                resolutionResult = INCurrencyAmountResolutionResult.unsupported(with: .notNow, alternativeCurrencyAmounts: [INCurrencyAmount(amount: Wallet.currentBalance, currencyCode: "BTC")])
            }
        }
        else {
            resolutionResult = INCurrencyAmountResolutionResult.needsValue()
        }
        
        completion(resolutionResult)
    }
    
    func confirm(sendPayment intent: INSendPaymentIntent, completion: (INSendPaymentIntentResponse) -> Swift.Void) {
        let resolutionResult = INSendPaymentIntentResponse(code: .success, userActivity: nil)
        completion(resolutionResult)
    }
    
    
    func handle(sendPayment intent: INSendPaymentIntent, completion: (INSendPaymentIntentResponse) -> Swift.Void) {
        
        var responseCode: INSendPaymentIntentResponseCode = .failure
        
        // Unwrap any optionals to send the request
        if let user = intent.payee?.displayName,
            address = Wallet.walletAddress(forUser: user),
            bitcoinAmount = intent.currencyAmount?.getBitcoinAmount() {
            
            // Actually send the money
            if Wallet.sendMoney(amount: bitcoinAmount.amount, toAddress: address, note: intent.note) {
                responseCode = .success
            }
            else {
                responseCode = .failure
            }
        }
        
        let userActivity = NSUserActivity(activityType: String(INSendPaymentIntent))
        let resolutionResult = INSendPaymentIntentResponse(code: responseCode, userActivity: userActivity)
        completion(resolutionResult)
    }
    
    

    

    
    
    // MARK: - INRequestPaymentIntentHandling methods
    
    
    func resolveCurrencyAmount(forRequestPayment intent: INRequestPaymentIntent, with completion: (INCurrencyAmountResolutionResult) -> Swift.Void) {
        let resolutionResult: INCurrencyAmountResolutionResult
        
        if let amount = intent.currencyAmount {
            resolutionResult = INCurrencyAmountResolutionResult.success(with: amount)
        }
        else {
            resolutionResult = INCurrencyAmountResolutionResult.notRequired()
        }
        
        completion(resolutionResult)
    }
    
    func resolvePayer(forRequestPayment intent: INRequestPaymentIntent, with completion: (INPersonResolutionResult) -> Void) {
        let resolutionResult: INPersonResolutionResult
        
        if let payer = intent.payer where Wallet.walletAddress(forUser: payer.displayName) != nil {
            resolutionResult = INPersonResolutionResult.success(with: payer)
        }
        else {
            resolutionResult = INPersonResolutionResult.notRequired()
        }
        
        completion(resolutionResult)
    }
    
    func confirm(requestPayment intent: INRequestPaymentIntent, completion: (INRequestPaymentIntentResponse) -> Swift.Void) {
        let resolutionResult = INRequestPaymentIntentResponse(code: .success, userActivity: nil)
        completion(resolutionResult)
    }
    
    func handle(requestPayment intent: INRequestPaymentIntent, completion: (INRequestPaymentIntentResponse) -> Void) {
        
        
        // Unwrap any optionals to send the request
        if let user = intent.payer?.displayName,
            address = Wallet.walletAddress(forUser: user),
            bitcoinAmount = intent.currencyAmount?.getBitcoinAmount() {
            
            // Actually request the money
            // We don't care about the result because we also display the QR code
            let _ = Wallet.request(amount: bitcoinAmount.amount, fromAddress: address, note: intent.note)
        }
        
        
        let userActivity = NSUserActivity(activityType: String(INRequestPaymentIntent))
        let resolutionResult = INRequestPaymentIntentResponse(code: .success, userActivity: userActivity)
        completion(resolutionResult)
    }
}
