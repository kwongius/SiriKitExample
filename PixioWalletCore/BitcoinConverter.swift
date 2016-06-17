//
//  BitcoinConverter.swift
//  PixioWallet
//
//  Created by Kevin Wong on 6/17/16.
//  Copyright © 2016 Pixio. All rights reserved.
//

import Foundation
import Intents

private enum Currency: String {
    case USD
    case CNY
    case EUR
    case BTC
    
    // 1 bitcoin in each currency
    var conversionRate: NSDecimalNumber {
        switch self {
        case USD:
            return 740
        case CNY:
            return 5000
        case EUR:
            return 666
        case BTC:
            return 1
        }
    }
    
    var subunit: Int16 {
        switch self {
        case BTC:
            return 8
        default:
            return 2
        }
    }
}

public extension INCurrencyAmount {
    
    public func getBitcoinAmount() -> INCurrencyAmount? {
        guard let bitcoinAmount = amount.convertToBitcoin(from: currencyCode) else {
            return nil
        }
        
        return INCurrencyAmount(amount: bitcoinAmount, currencyCode: "BTC")
    }
}

public extension NSDecimalNumber {
    
    public func convertToBitcoin(from currencyCode: String) -> NSDecimalNumber? {
        
        guard let currency = Currency(rawValue: currencyCode) else {
            return nil
        }
        
        let bitcoinAmount = self.dividing(by: currency.conversionRate)
        
        return bitcoinAmount.rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .roundBankers, scale: Currency.BTC.subunit, raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true))
    }
    
    
    public func convertFromBitcoin(to currencyCode: String) -> NSDecimalNumber? {
        guard let currency = Currency(rawValue: currencyCode) else {
            return nil
        }
        
        guard currency != .BTC else {
            return self
        }
        
        let currencyAmount = self.multiplying(by: currency.conversionRate)
        
        return currencyAmount.rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .roundBankers, scale: currency.subunit, raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true))
    }
}

