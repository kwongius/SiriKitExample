//
//  Wallet.swift
//  PixioWallet
//
//  Created by Kevin Wong on 6/17/16.
//  Copyright © 2016 Pixio. All rights reserved.
//

import Foundation

public enum Wallet {
    
    // Balance of the wallet
    private static var balance: NSDecimalNumber = 100
    
    public static var currentBalance: NSDecimalNumber {
        return Wallet.balance
    }
    
    public static let receiveAddress = "1AFakeReceiveBitcoinAddressForDemo"
    
    // Determine whether or not an amount can be spent
    public static func canSpend(_ amount: NSDecimalNumber) -> Bool {
        // Negative amount
        if amount.compare(0) == .orderedAscending {
            return false
        }

        // More than balance
        if Wallet.balance.compare(amount) == .orderedAscending {
            return false
        }
        
        return true
    }
    
    // Look up a valid wallet address for a given user
    public static func walletAddress(forUser: String) -> String? {
        return "1AFakeUserBitcoinAddressForDemo123"
    }

    // Send money to an address
    public static func sendMoney(amount: NSDecimalNumber, toAddress: String, note: String?) -> Bool {
        guard canSpend(amount) else {
            return false
        }
        
        // TODO: Actually send money
        return true
    }
    
    // Initiate a request for money from an address
    public static func request(amount: NSDecimalNumber, fromAddress: String, note: String?) -> Bool {
        // TODO: Actually request money
        return true
    }
}
