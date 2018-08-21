//
//  UIColor+theme.swift
//  FTTracker
//
//  Created by Dylan Bruschi on 8/20/18.
//  Copyright © 2018 Dylan Bruschi. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor{
        return  UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let themeRed = UIColor.rgb(red: 204, green: 0, blue: 0)
    static let themeBlue = UIColor.rgb(red: 74, green: 144, blue: 226)
    
}
