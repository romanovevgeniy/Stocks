//
//  Extensions.swift
//  Stocks-demo
//
//  Created by Евгений Романов on 30.10.2022.
//

import Foundation
import UIKit

//MARK: - Framing

extension UIView {
    
    var width: CGFloat {
        frame.size.width
    }
    
    var height: CGFloat {
        frame.size.height
    }
    
    var left: CGFloat {
        frame.origin.x
    }
    
    var right: CGFloat {
        left + width
    }
    
    var top: CGFloat {
        frame.origin.y
    }
    
    var bottom: CGFloat {
        top + height
    }
    
}
