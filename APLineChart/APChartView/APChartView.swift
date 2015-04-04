//
//  APChartView.swift
//  linechart
//
//  Created by Attilio Patania on 20/03/15.
//  Copyright (c) 2015 zemirco. All rights reserved.
//

import UIKit
import QuartzCore

// delegate method
protocol APChartViewDelegate {
    func didSelectNearDataPoint(selectedDots:[String:APChartPoint])
}


@IBDesignable class APChartView:UIView{
    var collectionLines:[APChartLine] = []
    var collectionMarkers:[APChartMarkerLine] = []
    var delegate: APChartViewDelegate!
    
    let labelAxesSize:CGSize = CGSize(width: 35.0, height: 20.0)
    var lineLayerStore: [CALayer] = []
    
    @IBInspectable var showAxes:Bool = true
    @IBInspectable var titleForX:String = "x axis"
    @IBInspectable var titleForY:String = "y axis"
    @IBInspectable var axesColor = UIColor(red: 96/255.0, green: 125/255.0, blue: 139/255.0, alpha: 1)
    //    @IBInspectable var positiveAreaColor = UIColor(red: 246/255.0, green: 153/255.0, blue: 136/255.0, alpha: 1)
    //    @IBInspectable var negativeAreaColor = UIColor(red: 114/255.0, green: 213/255.0, blue: 114/255.0, alpha: 1)
    
    @IBInspectable var showGrid:Bool = false
    @IBInspectable var gridColor = UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
    @IBInspectable var gridLinesX: CGFloat = 5.0
    @IBInspectable var gridLinesY: CGFloat = 5.0
    @IBInspectable var showLabelsX:Bool = false
    @IBInspectable var showLabelsY:Bool = false
    
    @IBInspectable var showDots:Bool = false
    @IBInspectable var dotsBackgroundColor:UIColor = UIColor.whiteColor()
    @IBInspectable var areaUnderLinesVisible:Bool = true
    
    var animationEnabled = true
    @IBInspectable var showMean:Bool = false
    @IBInspectable var showMeanProgressive:Bool = false
    @IBInspectable var showMax:Bool = false
    @IBInspectable var showMin:Bool = false
    
    var marginBottom:CGFloat = 50.0
    lazy var marginLeft:CGFloat = {
        return self.labelAxesSize.width + self.labelAxesSize.height
        }()
    var marginTop:CGFloat = 25
    var marginRight:CGFloat = 25
    var animationDuration: CFTimeInterval = 1
    
    let colors: [UIColor] = [
        UIColor.fromHex(0x1f77b4),
        UIColor.fromHex(0xff7f0e),
        UIColor.fromHex(0x2ca02c),
        UIColor.fromHex(0xd62728),
        UIColor.fromHex(0x9467bd),
        UIColor.fromHex(0x8c564b),
        UIColor.fromHex(0xe377c2),
        UIColor.fromHex(0x7f7f7f),
        UIColor.fromHex(0xbcbd22),
        UIColor.fromHex(0x17becf)
    ]
    
    
    var offsetX: Offset = Offset(min:0.0, max:1.0)
    var offsetY: Offset = Offset(min:0.0, max:1.0)
    
    var drawingArea:CGRect  = CGRectZero
    var pointBase:CGPoint = CGPointZero
    var pointZero:CGPoint {
        return drawingArea.origin
    }
    var selectetedXlayer:CAShapeLayer? = nil
    
    var lineMax :APChartMarkerLine?
    var lineMin :APChartMarkerLine?
    var removeAll: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var line = APChartLine(chartView: self, title: "mio", lineWidth: 2.0, lineColor: self.colors[1])
        line.addPoint( CGPoint(x: 23.0, y: 159.0))
        line.addPoint( CGPoint(x: 34.0, y: 137.0))
        line.addPoint(CGPoint(x: 36.0, y: 160.0))
        line.addPoint(CGPoint(x: 49.0, y: 125.0))
        line.addPoint(CGPoint(x: 61.0, y: 140.0))
        line.addPoint(CGPoint(x: 72.0, y: 132.0))
        line.addPoint(CGPoint(x: 78.0, y: 138.0))
        line.addPoint(CGPoint(x: 95.0, y: 138.0))
        line.addPoint(CGPoint(x: 98.0, y: 175.0))
        line.addPoint(CGPoint(x: 101.0, y: 102.0))
        line.addPoint(CGPoint(x: 102.0, y: 92.0))
        line.addPoint(CGPoint(x: 115.0, y: 88.0))
        self.addLine(line)
        
        
        var markerX = APChartMarkerLine(chartView: self, title: "x marker", x: 85.0, lineColor: UIColor.redColor() )
        
        self.addMarkerLine("x marker", x: 85.0 )
        self.addMarkerLine("y marker", y: 120.0 )
        
        self.setNeedsDisplay()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addLine(line:APChartLine){
        
        collectionLines.append(line)
    }

    func addMarkerLine(title:String, x:CGFloat) {
        
        var line = APChartMarkerLine(chartView: self, title: title, x: x, lineColor: UIColor.redColor())
        collectionMarkers.append(line)
    }
    

    func addMarkerLine(title:String, y:CGFloat){
        var line = APChartMarkerLine(chartView: self, title: title, y: y, lineColor: UIColor.blueColor())
        collectionMarkers.append(line)

    }
    
    override func drawRect(rect: CGRect) {
        if removeAll {
            var context = UIGraphicsGetCurrentContext()
            CGContextClearRect(context, rect)
            return
        }
        
        
        // remove all labels
        for view: AnyObject in self.subviews {
            view.removeFromSuperview()
        }
        
        // remove all lines on device rotation
        for lineLayer in lineLayerStore {
            lineLayer.removeFromSuperlayer()
        }
        lineLayerStore.removeAll()
        selectetedXlayer?.removeFromSuperlayer()
        
        updateDrawingArea()
        
        drawGrid()
        
        drawAxes()
        
        calculateOffsets()
        
        lineMax = nil
        lineMin = nil

        if showMax {
            lineMax = APChartMarkerLine(chartView: self, title: "Max", y: offsetY.maxValue, lineColor: UIColor.blueColor())
        }

        if showMin {
            lineMin = APChartMarkerLine(chartView: self, title: "Min", y: offsetY.minValue, lineColor: UIColor.blueColor())
        }
        
        
        updateLinesDataStoreScaled()
        
        drawXLabels()
        drawYLabels()
        
        
        var layer:CAShapeLayer? = nil
        for  lineData in collectionLines {
            
            lineData.showMeanValue = showMean
            lineData.showMeanValueProgressive = showMeanProgressive
            
            if let layer = lineData.drawLine() {
                self.layer.addSublayer(layer)
                self.lineLayerStore.append(layer)
            }
            
            lineData.drawMeanValue()
            lineData.drawMeanProgressive()
            
            
            // draw dots
            if showDots {
                if let dotsLayer = lineData.drawDots(dotsBackgroundColor) {
                    for ll in dotsLayer {
                        self.layer.addSublayer(ll)
                        self.lineLayerStore.append(ll)
                    }
                }
            }
            
            // draw area under line chart
            if areaUnderLinesVisible { lineData.drawAreaBeneathLineChart() }
            
        }
        
        if let markerLine = lineMax? {
            if let layer = markerLine.drawLine() {
                self.layer.addSublayer(layer)
                self.lineLayerStore.append(layer)
            }
        }
        if let markerLine = lineMin? {
            if let layer = markerLine.drawLine() {
                self.layer.addSublayer(layer)
                self.lineLayerStore.append(layer)
            }
        }

        for markerLine in collectionMarkers {
            if let layer = markerLine.drawLine() {
                self.layer.addSublayer(layer)
                self.lineLayerStore.append(layer)
            }
        }
        
    }
    
    
    func updateDrawingArea(){
        drawingArea = CGRect(x: marginLeft, y: self.bounds.height-marginBottom, width: self.bounds.width  - marginLeft - marginRight, height: self.bounds.height - marginTop  - marginBottom)
        
        if !showLabelsX {
            drawingArea.origin.y = self.bounds.height-self.labelAxesSize.height
            drawingArea.size.height = self.bounds.height - self.labelAxesSize.height - marginTop
        }
        if !showLabelsY {
            drawingArea.origin.x = self.labelAxesSize.height
            drawingArea.size.width = self.bounds.width - self.labelAxesSize.height - marginRight
        }
        
    }
    
    /**
    * Draw grid.
    */
    func drawGrid() {
        if !showGrid {
            return
        }
        drawXGrid()
        drawYGrid()
    }
    
    
    /**
    * Draw x grid.
    */
    func drawXGrid() {
        var height = self.bounds.height
        var width = self.bounds.width
        
        var space = drawingArea.width / gridLinesX
        var context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, gridColor.CGColor)
        var x:CGFloat = drawingArea.origin.x;
        var step:CGFloat = 0.0
        while step++ < gridLinesX {
            x +=  space
            CGContextMoveToPoint(context, x,  drawingArea.origin.y)
            CGContextAddLineToPoint(context, x , drawingArea.origin.y - drawingArea.height)
        }
        CGContextStrokePath(context)
    }
    
    
    
    /**
    * Draw y grid.
    */
    func drawYGrid() {
        
        var delta_h = drawingArea.height  / gridLinesY
        var context = UIGraphicsGetCurrentContext()
        var y:CGFloat = drawingArea.origin.y
        var step:CGFloat = 0.0
        while step++ < gridLinesY {

            y -= delta_h
            CGContextMoveToPoint( context, drawingArea.origin.x, y )
            CGContextAddLineToPoint(context, drawingArea.origin.x + drawingArea.width, y)
            
        }
        CGContextStrokePath(context)
    }
    
    /**
    * Draw x and y axis.
    */
    func drawAxes() {
        if (!showAxes){
            return
        }
        var height = self.bounds.height
        var width = self.bounds.width
        
        var context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, axesColor.CGColor)
        // draw x-axis
        CGContextMoveToPoint(context, drawingArea.origin.x, drawingArea.origin.y)
        CGContextAddLineToPoint(context, drawingArea.origin.x + drawingArea.width+5,  drawingArea.origin.y)
        CGContextAddLineToPoint(context, drawingArea.origin.x + drawingArea.width+5,  drawingArea.origin.y-4)
        CGContextAddLineToPoint(context, drawingArea.origin.x + drawingArea.width+5+10,  drawingArea.origin.y)
        CGContextAddLineToPoint(context, drawingArea.origin.x + drawingArea.width+5,  drawingArea.origin.y+4)
        CGContextAddLineToPoint(context, drawingArea.origin.x + drawingArea.width+5,  drawingArea.origin.y-4)
        
        CGContextStrokePath(context)
        // draw y-axis
        CGContextMoveToPoint(context, drawingArea.origin.x, drawingArea.origin.y)
        CGContextAddLineToPoint(context, drawingArea.origin.x, marginTop - 5.0 )
        CGContextAddLineToPoint(context, drawingArea.origin.x-4.0, marginTop - 5.0 )
        CGContextAddLineToPoint(context, drawingArea.origin.x, marginTop - 5.0 - 10.0)
        CGContextAddLineToPoint(context, drawingArea.origin.x+4.0, marginTop - 5.0 )
        CGContextAddLineToPoint(context, drawingArea.origin.x-4.0, marginTop - 5.0 )
        CGContextStrokePath(context)
        
        var xAxeTitle = UILabel(frame: CGRect(x: pointZero.x, y: height - labelAxesSize.height, width: drawingArea.width, height: labelAxesSize.height))
        xAxeTitle.font = UIFont.italicSystemFontOfSize(12.0)
        xAxeTitle.textAlignment = .Right
        xAxeTitle.backgroundColor = UIColor.clearColor()
        xAxeTitle.text = titleForX
        self.addSubview(xAxeTitle)
        
        var yAxeTitle = UILabel(frame: CGRect(x: -labelAxesSize.height, y: pointZero.y, width: drawingArea.height, height:  labelAxesSize.height))
        yAxeTitle.font = UIFont.italicSystemFontOfSize(12.0)
        yAxeTitle.textAlignment = .Right
        yAxeTitle.text = titleForY
        yAxeTitle.backgroundColor = UIColor.clearColor()

        var yframe = yAxeTitle.frame
        yAxeTitle.layer.anchorPoint = CGPoint(x:(yframe.size.height / yframe.size.width * 0.5), y: -0.5) // Anchor points are in unit space
        yAxeTitle.frame = yframe; // Moving the anchor point moves the layer's position, this is a simple way to re-set
        yAxeTitle.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI)/2)
        
        self.addSubview(yAxeTitle)
        
    }
    
    func drawMarkers() {
        if (!showAxes){
            return
        }
        var height = self.bounds.height
        var width = self.bounds.width
        
        var context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, axesColor.CGColor)
        // draw x-axis
        CGContextMoveToPoint(context, drawingArea.origin.x, drawingArea.origin.y)
        CGContextAddLineToPoint(context, drawingArea.origin.x + drawingArea.width+5,  drawingArea.origin.y)
        CGContextAddLineToPoint(context, drawingArea.origin.x + drawingArea.width+5,  drawingArea.origin.y-4)
        CGContextAddLineToPoint(context, drawingArea.origin.x + drawingArea.width+5+10,  drawingArea.origin.y)
        CGContextAddLineToPoint(context, drawingArea.origin.x + drawingArea.width+5,  drawingArea.origin.y+4)
        CGContextAddLineToPoint(context, drawingArea.origin.x + drawingArea.width+5,  drawingArea.origin.y-4)
        
        CGContextStrokePath(context)
        // draw y-axis
        CGContextMoveToPoint(context, drawingArea.origin.x, drawingArea.origin.y)
        CGContextAddLineToPoint(context, drawingArea.origin.x, marginTop - 5.0 )
        CGContextAddLineToPoint(context, drawingArea.origin.x-4.0, marginTop - 5.0 )
        CGContextAddLineToPoint(context, drawingArea.origin.x, marginTop - 5.0 - 10.0)
        CGContextAddLineToPoint(context, drawingArea.origin.x+4.0, marginTop - 5.0 )
        CGContextAddLineToPoint(context, drawingArea.origin.x-4.0, marginTop - 5.0 )
        CGContextStrokePath(context)
        
        var xAxeTitle = UILabel(frame: CGRect(x: pointZero.x, y: height - labelAxesSize.height, width: drawingArea.width, height: labelAxesSize.height))
        xAxeTitle.font = UIFont.italicSystemFontOfSize(12.0)
        xAxeTitle.textAlignment = .Right
        xAxeTitle.backgroundColor = UIColor.clearColor()
        xAxeTitle.text = titleForX
        self.addSubview(xAxeTitle)
        
        var yAxeTitle = UILabel(frame: CGRect(x: -labelAxesSize.height, y: pointZero.y, width: drawingArea.height, height:  labelAxesSize.height))
        yAxeTitle.font = UIFont.italicSystemFontOfSize(12.0)
        yAxeTitle.textAlignment = .Right
        yAxeTitle.text = titleForY
        yAxeTitle.backgroundColor = UIColor.clearColor()
       
        var yframe = yAxeTitle.frame
        yAxeTitle.layer.anchorPoint = CGPoint(x:(yframe.size.height / yframe.size.width * 0.5), y: -0.5) // Anchor points are in unit space
        yAxeTitle.frame = yframe; // Moving the anchor point moves the layer's position, this is a simple way to re-set
        yAxeTitle.transform = CGAffineTransformMakeRotation(-CGFloat(M_PI)/2)
        
        self.addSubview(yAxeTitle)
        
    }
    
    
    func calculateOffsets()  {
        offsetX = Offset(min:0.0, max:1.0)
        offsetY = Offset(min:0.0, max:1.0)
        
        if collectionLines.count == 0 {
            return
        }
        if collectionLines[0].dots.count == 0 {
            return
        }
        var p = collectionLines[0].dots[0]

        offsetX = Offset(min:p.dot.x, max:p.dot.x )
        offsetY = Offset(min:p.dot.y, max:p.dot.y )
        
        for line in collectionLines {
            
            for curr:APChartPoint in line.dots {
                offsetX.updateMinMax(curr.dot.x)
                offsetY.updateMinMax(curr.dot.y)
            }
        }
        
        var x = offsetX.delta()/10
        offsetX.min -= x
        offsetX.max += x
        var y = offsetY.delta()/10
        offsetY.min -= y
        offsetY.max += y
        
        if x > 0.0 && x < offsetX.min {
            offsetX.min -= 2*y
        }
        if y > 0.0 && y < offsetY.min {
            offsetY.min -= 2*y
        }
        
    }
    
    func updateLinesDataStoreScaled() {
        
        var x_factor = drawingArea.width / ( offsetX.delta()) // - pointZero.x )
        var y_factor = drawingArea.height /  offsetY.delta()
        var factorPoint = CGPoint(x: x_factor, y: y_factor)
        
        pointBase = CGPoint(x: pointZero.x-offsetX.min*x_factor , y: pointZero.y+offsetY.min*y_factor)
        for line in collectionLines {
            line.updatePoints( factorPoint, offset: pointBase )
        }
        
        for line in collectionMarkers {
            line.updatePoints( factorPoint, offset: pointBase )
        }
        
        lineMin?.updatePoints(factorPoint, offset: pointBase)
        lineMax?.updatePoints(factorPoint, offset: pointBase)
        
    }
    
    /**
    * Draw x labels.
    */
    func drawXLabels() {
        if !showLabelsX {
            return
        }
        if (offsetX.min > 0 ){
            var label = UILabel(frame: CGRect(x: pointZero.x-6.0, y: pointZero.y+12.0, width: pointZero.x-4.0-16.0, height: 16.0))
            label.backgroundColor = UIColor.clearColor()
            label.font = UIFont.boldSystemFontOfSize(10)
            label.textAlignment = NSTextAlignment.Left
            label.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) * 7 / 18)
            label.sizeToFit()
            label.text = "\(offsetX.min.round2dec())"
            self.addSubview(label)
        }
        
        var delta = drawingArea.width  / gridLinesX
        var xValue_delta = offsetX.delta()  / gridLinesX
        var x:CGFloat = pointZero.x
        var step:CGFloat = 0.0
        while step++ < gridLinesX {
            x += delta
            
            var label = UILabel(frame: CGRect(x: x-12.0, y: pointZero.y+12.0, width: pointZero.x-4.0-16.0, height: 16.0))
            label.font = UIFont.boldSystemFontOfSize(10)
            label.textAlignment = NSTextAlignment.Left
            label.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) * 7 / 18)
            label.text = "\((offsetX.min + xValue_delta*step).round2dec())"
            label.sizeToFit()

            self.addSubview(label)
        }
        
    }
    
    /**
    * Draw y labels.
    */
    func drawYLabels() {
        if !showLabelsY{
            return
        }
        
        if (offsetY.min > 0 ) {
            var label = UILabel(frame: CGRect(x: 18.0, y:  pointZero.y-16.0, width: pointZero.x-4.0-16.0, height: 16.0))
            label.font = UIFont.systemFontOfSize(10)
            label.textAlignment = NSTextAlignment.Right
            label.text = "\(offsetY.min.round2dec())"
            label.sizeToFit()
      
            self.addSubview(label)
        }
        
        var delta_h = drawingArea.height  / gridLinesY
        var yValue_delta = offsetY.delta()  / gridLinesY
        var y:CGFloat = pointZero.y
        var step:CGFloat = 0.0
        while step++ < gridLinesY {
            y -= delta_h
            
            var label = UILabel(frame: CGRect(x: 18.0, y: y-8.0, width: pointZero.x-4.0-16.0, height: 16.0))
            label.font = UIFont.systemFontOfSize(10)
            label.textAlignment = NSTextAlignment.Right
            label.text = "\((yValue_delta*step+offsetY.min).round2dec())"
            label.sizeToFit()
      
            self.addSubview(label)
            
        }
    }
    
    
    func getClosetLineDot(selectedPoint:CGPoint) -> [String:APChartPoint]?{
        var delta:CGFloat = 100000.0
        var diff:CGFloat = 0.0
        var selectedDot:[String:APChartPoint] = [:]
        for line in collectionLines {
            delta = 5.0
            for (index,dot) in enumerate(line.dots){
                dot.backgroundColor = dotsBackgroundColor
                
                diff  =  selectedPoint.distanceXFrom(dot.point)
                if delta > diff
                {
                    selectedDot[line.title] = dot
                    delta = diff
                }
            }
        }
        for (lineTitle, dot) in selectedDot {
            dot.backgroundColor = dotsBackgroundColor.lighterColorForColor()
        }
        return selectedDot
    }
    
    /**
    * Handle touch events.
    */
    func handleTouchEvents(touches: NSSet!, event: UIEvent!) {
        if (self.collectionLines.isEmpty) { return }
        
        var point: AnyObject! = touches.anyObject()
        var selectedPoint = point.locationInView(self)
        
        var bpath = UIBezierPath()
        bpath.moveToPoint(CGPoint(x: selectedPoint.x, y: marginTop))
        bpath.addLineToPoint(CGPoint(x: selectedPoint.x, y: pointZero.y))
        selectetedXlayer?.removeFromSuperlayer()
        
        selectetedXlayer = CAShapeLayer()
        selectetedXlayer!.frame = self.bounds
        selectetedXlayer!.path = bpath.CGPath
        selectetedXlayer!.strokeColor = UIColor.purpleColor().CGColor //colors[lineIndex].CGColor
        selectetedXlayer!.fillColor = nil
        selectetedXlayer!.lineWidth = 1.0
        self.layer.addSublayer(selectetedXlayer)
        
        
        if let closestDots = getClosetLineDot(selectedPoint) {
            delegate?.didSelectNearDataPoint(closestDots)
        }
        
    }
    
    
    /**
    * Listen on touch end event.
    */
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        handleTouchEvents(touches, event: event)
    }
    
    /**
    * Listen on touch move event
    */
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        handleTouchEvents(touches, event: event)
    }
    
}

class Offset {
    var min:CGFloat = 0.0
    var max:CGFloat = 1.0
    var maxValue:CGFloat = 1.0
    var minValue:CGFloat = 0.0
    
    init(min:CGFloat, max:CGFloat){
        self.min = min
        self.max = max
    }
    func updateMinMax(value:CGFloat){
        if self.min > value {
            self.min = value
        }
        if self.max <  value {
            self.max = value
        }
        
        self.maxValue = self.max
        self.minValue = self.min
    }
    
    func delta() -> CGFloat {
        return (self.max - self.min)
    }
}
