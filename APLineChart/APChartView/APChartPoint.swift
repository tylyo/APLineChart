//
//  APChartPoint.swift
//  linechart
//
//  Created by Attilio Patania on 20/03/15.
//  Copyright (c) 2015 zemirco. All rights reserved.
//

import UIKit

extension CGFloat {
    func updatePointX(_ factor:CGFloat, _ offset:CGFloat) -> CGFloat {
        var newX = offset + self * factor
        
        if (newX.isNaN) {
            newX = 0
        }
        
        return newX
    }
    func updatePointY (_ factor:CGFloat, _ offset:CGFloat) -> CGFloat {
        var newY = offset - self * factor
        
        if (newY.isNaN) {
            newY = 0
        }
        
        return newY
    }
}
class APChartPoint {
    var dot:CGPoint = CGPoint(x: 0.0, y: 0.0)
    var point:CGPoint = CGPoint(x:0.0, y:0.0)
    var color:UIColor = UIColor.gray
    var backgroundColor:UIColor = UIColor.gray
    var chart:APChartView!
    var extra:[String:AnyObject?] = [:]

    var outerRadius: CGFloat = 12
    var innerRadius: CGFloat = 8
    var outerRadiusHighlighted: CGFloat = 12
    var innerRadiusHighlighted: CGFloat = 8
    
    required init(_ dot: CGPoint){
        self.dot = dot
    }
    
    required init(_ dot: CGPoint, extra:[String:AnyObject?]){
        self.dot = dot
        self.extra = extra
    }
    
    func updatePoint  (_ factor:CGPoint, offset:CGPoint ) -> APChartPoint{
        
        self.point = CGPoint( x: dot.x.updatePointX(factor.x, offset.x) ,  y: dot.y.updatePointY(factor.y, offset.y))
        return self
    }
    
    
    /**
    * Draw dot at every data point.
    */
    func drawDot(_ bgColor:UIColor) -> CALayer{
        
        let xValue = point.x - outerRadius/2
        let yValue = point.y - outerRadius/2
        
        // draw custom layer with another layer in the center
        let dotLayer = CALayer()
        dotLayer.backgroundColor = bgColor.cgColor
        dotLayer.cornerRadius = outerRadius / 2
        dotLayer.frame = CGRect(x: xValue, y: yValue, width: outerRadius, height: outerRadius)
        
        let dotLayerInner = CALayer()
        let inset = dotLayer.bounds.size.width - innerRadius
        dotLayerInner.backgroundColor = color.cgColor
        dotLayerInner.cornerRadius = innerRadius / 2
        dotLayerInner.frame = dotLayer.bounds.insetBy(dx: inset/2, dy: inset/2)
        
        
        dotLayer.addSublayer(dotLayerInner)
        
        // animate opacity
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.8
        animation.fromValue = 0
        animation.toValue = 1
        dotLayer.add(animation, forKey: "opacity")
        
        return dotLayer
    }
    
}
