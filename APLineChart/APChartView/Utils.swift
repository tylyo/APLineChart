//
//  Utils.swift
//  linechart
//
//  Created by Attilio Patania on 23/03/15.
//  Copyright (c) 2015 zemirco. All rights reserved.
//

import UIKit


extension UIColor {
    func lighterColorForColor() -> UIColor {
        
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        
        if self.getRed(&r, green: &g, blue: &b, alpha: &a){
            return UIColor(red: min(r + 0.2, 1.0), green: min(g + 0.2, 1.0), blue: min(b + 0.2, 1.0), alpha:0.4)
        }
        
        return self
    }
    
    class func fromHex(_ hex: Int) -> UIColor {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}

extension CGPoint {
    func distanceFrom(_ toPoint:CGPoint) -> CGFloat {
        let xDist2:CGFloat  = abs(self.x - toPoint.x)*abs(self.y - toPoint.y)
        let yDist2:CGFloat = abs(self.y - toPoint.y)*abs(self.y - toPoint.y);
        return sqrt( xDist2 + yDist2 );
    }
    
    func distanceXFrom( _ toPoint:CGPoint) -> CGFloat {
        let xDist2:CGFloat  = abs(self.x - toPoint.x)
        return xDist2;
    }

}


extension Double {
    mutating func round2dec() -> Double {
        return Double(Darwin.round(self*100)/100)
    }
}
extension CGFloat {
    mutating func round2dec() -> CGFloat {
        return CGFloat(Darwin.round(self*100)/100)
    }
}
