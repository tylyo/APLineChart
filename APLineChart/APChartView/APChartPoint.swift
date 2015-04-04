//
//  APChartPoint.swift
//  linechart
//
//  Created by Attilio Patania on 20/03/15.
//  Copyright (c) 2015 zemirco. All rights reserved.
//

import UIKit

extension CGFloat {
    func updatePointX(factor:CGFloat, _ offset:CGFloat) -> CGFloat {
        return offset + self * factor
    }
    func updatePointY (factor:CGFloat, _ offset:CGFloat) -> CGFloat {
        return offset - self * factor
    }
}
class APChartPoint {
    var dot:CGPoint = CGPoint(x: 0.0, y: 0.0)
    var point:CGPoint = CGPoint(x:0.0, y:0.0)
    var color:UIColor = UIColor.grayColor()
    var backgroundColor:UIColor = UIColor.grayColor()
    var chart:APChartView!
    var extra:[String:AnyObject!] = [:]

    var outerRadius: CGFloat = 12
    var innerRadius: CGFloat = 8
    var outerRadiusHighlighted: CGFloat = 12
    var innerRadiusHighlighted: CGFloat = 8
    
    required init(_ dot: CGPoint){
        self.dot = dot
    }
    
    required init(_ dot: CGPoint, extra:[String:AnyObject!]){
        self.dot = dot
        self.extra = extra
    }
    
    func updatePoint  (factor:CGPoint, offset:CGPoint ) -> APChartPoint{
        
        self.point = CGPoint( x: dot.x.updatePointX(factor.x, offset.x) ,  y: dot.y.updatePointY(factor.y, offset.y))
        return self
    }
    
    
    /**
    * Draw dot at every data point.
    */
    func drawDot(bgColor:UIColor) -> CALayer{
        
        var xValue = point.x - outerRadius/2
        var yValue = point.y - outerRadius/2
        
        // draw custom layer with another layer in the center
        var dotLayer = CALayer()
        dotLayer.backgroundColor = bgColor.CGColor
        dotLayer.cornerRadius = outerRadius / 2
        dotLayer.frame = CGRect(x: xValue, y: yValue, width: outerRadius, height: outerRadius)
        
        var dotLayerInner = CALayer()
        var inset = dotLayer.bounds.size.width - innerRadius
        dotLayerInner.backgroundColor = color.CGColor
        dotLayerInner.cornerRadius = innerRadius / 2
        dotLayerInner.frame = CGRectInset(dotLayer.bounds, inset/2, inset/2)
        
        
        dotLayer.addSublayer(dotLayerInner)
        
        // animate opacity
        var animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.8
        animation.fromValue = 0
        animation.toValue = 1
        dotLayer.addAnimation(animation, forKey: "opacity")
        
        return dotLayer
    }
    
}
