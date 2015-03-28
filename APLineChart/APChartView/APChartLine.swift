//
//  APChartLine.swift
//  linechart
//
//  Created by Attilio Patania on 20/03/15.
//  Copyright (c) 2015 zemirco. All rights reserved.
//

import UIKit
import QuartzCore
class APChartLine  {
    var chart:APChartView!
    var dots:[APChartPoint] = []
    var title:String = "line"
    var lineColor:UIColor = UIColor.blackColor()
    var lineWidth:CGFloat = 2.0
    var showMeanValue:Bool = false
    var meanValue:CGFloat = 0.0
    var meanCoord:CGFloat = 0.0
    var showMeanValueProgressive:Bool = false
    var meanCoordsProgressive:[CGFloat] = []
    var extra:[String:AnyObject!] = [:]
    
    init(chartView:APChartView, title:String, points:[APChartPoint]) {
        self.chart = chartView
        self.title = title
        self.dots = points
    }
    init(chartView:APChartView, title:String, lineWidth:CGFloat, lineColor:UIColor) {
        self.chart = chartView
        self.title = title
        self.lineWidth = lineWidth
        self.lineColor = lineColor
    }
    
    
    func addPoint(point:CGPoint) {
        println("addPoint \(point)")
        var dot = APChartPoint(point)
        dot.chart = chart
        dot.color = lineColor
        self.dots.append(dot)
        
    }
    func addPoint(point:CGPoint, extra:[String:AnyObject!]) {
        println("addPoint \(point)")
        var dot = APChartPoint(point)
        dot.chart = chart
        dot.color = lineColor
        dot.extra = extra
        self.dots.append(dot)
        
    }
    func clear(){
        dots.removeAll()
    }
    
    
    func updatePoints(factorPoint:CGPoint, offset:CGPoint){
        
        for (index, dot) in enumerate(dots){
            dots[index] = dot.updatePoint(factorPoint, offset: offset)
        }
        
    }
    
    func drawLine() -> CAShapeLayer? {
        //        let currentLine = linesDataStore[lineIndex]
        //         println("APChartLine.drawLine \(title) [\(dots.count)] \(lineWidth), p0:\(chart.pointZero)")
        
        
        var bpath = UIBezierPath()
        bpath.moveToPoint(CGPoint(x: dots[0].point.x, y: dots[0].point.y))
        
        for (index, dot) in enumerate(dots) {
            
            bpath.addLineToPoint(dot.point)
            if showMeanValue {
                if index == 0 {
                    meanValue = dot.dot.y
                    meanCoord = dot.point.y
                    meanCoordsProgressive.append(meanCoord)
                    continue
                }
                meanValue = (CGFloat(index)*meanValue +  dot.dot.y ) / CGFloat(index+1)
                meanCoord = (CGFloat(index)*meanCoord +  dot.point.y ) / CGFloat(index+1)
                meanCoordsProgressive.append(meanCoord)
                
            }
        }
        
        UIColor.clearColor().setStroke()
        bpath.lineCapStyle = kCGLineCapRound
        bpath.stroke()
        //
        var layer = CAShapeLayer()
        layer.frame = self.chart.bounds
        layer.path = bpath.CGPath
        layer.strokeColor = lineColor.CGColor //colors[lineIndex].CGColor
        layer.fillColor = nil
        layer.lineWidth = lineWidth
        
        var animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.0
        animation.fromValue = 0
        animation.toValue = 1
        layer.addAnimation(animation, forKey: "strokeEnd")
        
        return layer
    }
    
    func drawDots(bgColor:UIColor) -> [CALayer]? {
        var retLayers:[CALayer]? = []
        for currDot in dots {
            currDot.backgroundColor = lineColor
            retLayers?.append(currDot.drawDot(bgColor))
        }
        return retLayers
    }
    
    /**
    * Fill area between line chart and x-axis.
    */
    func drawAreaBeneathLineChart() {
        
        var bpath = UIBezierPath()
        bpath.moveToPoint(CGPoint(x: dots[0].point.x, y: chart.pointZero.y))
        for dot in dots {
            bpath.addLineToPoint(dot.point)
        }
        bpath.addLineToPoint(CGPoint(x: dots[dots.count-1].point.x, y: chart.pointZero.y))
        var bgColor = lineColor.lighterColorForColor()
        
        bgColor.setFill()
        bpath.lineCapStyle = kCGLineCapRound
        bpath.fill()
        bpath.stroke()
        
    }
    
    func drawMeanProgressive(){
        if !showMeanValueProgressive || meanCoordsProgressive.count == 0 {
            return
        }
        
        var meanPath = UIBezierPath()
        meanPath.moveToPoint(CGPoint(x: dots[0].point.x, y: meanCoordsProgressive[0]))
        for (index,curr) in enumerate(dots) {
            meanPath.addLineToPoint(CGPoint(x: curr.point.x, y: meanCoordsProgressive[index]))
            
        }
        
        
        meanPath.lineWidth = 1.0
        meanPath.stroke()
        
        //
        var layer = CAShapeLayer()
        layer.frame = chart.bounds
        layer.path = meanPath.CGPath
        layer.strokeColor = lineColor.CGColor //colors[lineIndex].CGColor
        layer.fillColor = nil
        layer.lineWidth = 1.0
        layer.lineDashPattern = [6,2,8,2]
        
        var animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.0
        animation.fromValue = 0
        animation.toValue = 1
        layer.addAnimation(animation, forKey: "strokeEnd")
        
        var lblMean = UILabel(frame: CGRect(origin: CGPoint(x: chart.drawingArea.origin.x, y: meanCoord), size: chart.labelAxesSize))
        lblMean.font = UIFont.italicSystemFontOfSize(10.0)
        lblMean.textAlignment = .Left
        lblMean.text = "\(meanValue.round2dec())"
        lblMean.textColor = lineColor
        chart.addSubview(lblMean)
        chart.layer.addSublayer(layer)
        chart.lineLayerStore.append(layer)
        
    }
    
    func drawMeanValue(){
        if !showMeanValue || meanValue == 0.0  {
            return
        }
        
        var meanPath = UIBezierPath()
        meanPath.moveToPoint(CGPoint(x: chart.drawingArea.origin.x, y: meanCoord))
        meanPath.addLineToPoint(CGPoint(x: chart.drawingArea.origin.x+chart.drawingArea.width, y: meanCoord))
        
        meanPath.setLineDash([6,2], count: 3, phase: 1.0)
        meanPath.lineWidth = 1.0
        meanPath.stroke()
        
        //
        var layer = CAShapeLayer()
        layer.frame = chart.bounds
        layer.path = meanPath.CGPath
        layer.strokeColor = lineColor.CGColor //colors[lineIndex].CGColor
        layer.fillColor = nil
        layer.lineWidth = 1.0
        layer.lineDashPattern = [6,2]
        //
        var animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.0
        animation.fromValue = 0
        animation.toValue = 1
        layer.addAnimation(animation, forKey: "strokeEnd")
        var lblMean = UILabel(frame: CGRect(origin: CGPoint(x: chart.drawingArea.origin.x, y: meanCoord), size: chart.labelAxesSize))
        lblMean.font = UIFont.italicSystemFontOfSize(10.0)
        lblMean.textAlignment = .Left
        lblMean.text = "\(meanValue.round2dec())"
        lblMean.textColor = lineColor
        chart.addSubview(lblMean)
        chart.layer.addSublayer(layer)
        chart.lineLayerStore.append(layer)
        
    }
    
}
