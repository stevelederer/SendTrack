//
//  LegalTermsViewController.swift
//  SendTrack
//
//  Created by Steve Lederer on 2/22/19.
//  Copyright © 2019 Steve Lederer. All rights reserved.
//

import UIKit

class LegalTermsViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.layer.cornerRadius = doneButton.frame.height / 2
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
