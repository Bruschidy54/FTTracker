//
//  FTTextField.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 10/13/17.
//  Copyright © 2017 Dylan Bruschi. All rights reserved.
//

import UIKit

class FTTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.cornerRadius = 5
    }
    
    override func becomeFirstResponder() -> Bool {
        let myColor: UIColor = UIColor.blue
        self.layer.borderColor = myColor.cgColor
        self.layer.borderWidth = 1.0
        
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        let myColor: UIColor = UIColor.darkGray
        self.layer.borderColor = myColor.cgColor
        self.layer.borderWidth = 0
        
        return super.resignFirstResponder()
    }

}
