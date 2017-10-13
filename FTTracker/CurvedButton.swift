//
//  CurvedButton.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 10/12/17.
//  Copyright © 2017 Dylan Bruschi. All rights reserved.
//

import UIKit

class CurvedButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 10
    }

}
