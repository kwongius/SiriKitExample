//
//  ViewController.swift
//  PixioWallet
//
//  Created by Kevin Wong on 6/17/16.
//  Copyright © 2016 Pixio. All rights reserved.
//

import UIKit
import Intents

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func authorizeSiriKit() {
        INPreferences.requestSiriAuthorization { status in
            switch status {
            case .authorized:
                print("Siri: Authorized")
            default:
                print("Siri: Not authorized")
            }
        }
    }
}

