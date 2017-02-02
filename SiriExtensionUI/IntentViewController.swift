//
//  IntentViewController.swift
//  SiriExtensionUI
//
//  Created by Kevin Wong on 6/17/16.
//  Copyright © 2016 Pixio. All rights reserved.
//

import IntentsUI
import PixioWalletCore

// As an example, this extension's Info.plist has been configured to handle interactions for INStartWorkoutIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Start my workout using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configure(with interaction: INInteraction!, context: INUIHostedViewContext, completion: ((CGSize) -> Void)!) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
        
        guard let intent = interaction.intent as? INRequestPaymentIntent else {
            completion(.zero)
            return
        }

        let payer = intent.payer
        let amount = intent.currencyAmount
        
        // Compose parameters for the QR code image
        var params = [String : String]()
        if let note = intent.note {
            params["message"] = note
        }
        if let amount = amount?.getBitcoinAmount()?.amount {
            params["amount"] = amount.description
        }
        
        
        var compontents = URLComponents(string: "bitcoin:\(Wallet.receiveAddress)")!
        compontents.queryItems = params.map({ k, v in URLQueryItem(name: k, value: v) })
        

        // Only set the image if the payer exists (the payment is sent through the server)
        if payer == nil {
            let image = QRCode.generateImage((compontents.url?.absoluteString)!, avatarImage: nil)
            imageView.image = image
        }
        else {
            imageView.image = nil
        }
        
        label.text = amount?.getBitcoinAmount()?.amount.map({ $0.description + " BTC" })
        
        completion(desiredSize)
    }
    
    var desiredSize: CGSize {
        return self.extensionContext!.hostedViewMaximumAllowedSize
    }
    
}
