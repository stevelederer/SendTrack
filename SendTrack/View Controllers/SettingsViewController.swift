//
//  SettingsViewController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/14/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var contactUsButton: UIButton!
    
    let emailComposer = MessageComposer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactUsButton.layer.cornerRadius = 10
        IAPHelper.shared.fetchAvailableProducts()
        
        IAPHelper.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else { return }
            if type == .purchased {
                let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: { (alert) in })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func consumable(_ sender: UIButton) {
        IAPHelper.shared.purchaseMyProduct(index: 0)
    }
    
    @IBAction func contactUsButtonTapped(_ sender: UIButton) {
        if (self.emailComposer.canSendEmail()) {
            let emailComposerVC = self.emailComposer.composeEmail()
            self.present(emailComposerVC, animated: true, completion: nil)
        }
    }
    
    
    // Do any additional setup after loading the view.
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
