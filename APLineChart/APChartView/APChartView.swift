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
    func didSelectNearDataPoint(_ selectedDots:[String:APChartPoint])
}


@IBDesignable class APChartView:UIView,UIScrollViewDelegate{
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
    @IBInspectable var dotsBackgroundColor:UIColor = UIColor.white
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
    
    var drawingArea:CGRect  = CGRect.zero
    var pointBase:CGPoint = CGPoint.zero
    var pointZero:CGPoint {
        return drawingArea.origin
    }
    var selectetedXlayer:CAShapeLayer? = nil
    
    var lineMax :APChartMarkerLine?
    var lineMin :APChartMarkerLine?
    var removeAll: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let line = APChartLine(chartView: self, title: "mio", lineWidth: 2.0, lineColor: self.colors[1])
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
        
        
        _ = APChartMarkerLine(chartView: self, title: "x marker", x: 85.0, lineColor: UIColor.red )
        
        self.addMarkerLine("x marker", x: 85.0 )
        self.addMarkerLine("y marker", y: 120.0 )
        self.setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addLine(_ line:APChartLine){
        
        collectionLines.append(line)
    }

    func addMarkerLine(_ title:String, x:CGFloat) {
        
        let line = APChartMarkerLine(chartView: self, title: title, x: x, lineColor: UIColor.red)
        collectionMarkers.append(line)
    }
    

    func addMarkerLine(_ title:String, y:CGFloat){
        let line = APChartMarkerLine(chartView: self, title: title, y: y, lineColor: UIColor.blue)
        collectionMarkers.append(line)

    }
    
    override func draw(_ rect: CGRect) {
        if removeAll {
            let context = UIGraphicsGetCurrentContext()
            context?.clear(rect)
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
            lineMax = APChartMarkerLine(chartView: self, title: "Max", y: offsetY.maxValue, lineColor: UIColor.blue)
        }

        if showMin {
            lineMin = APChartMarkerLine(chartView: self, title: "Min", y: offsetY.minValue, lineColor: UIColor.blue)
        }
        
        
        updateLinesDataStoreScaled()
        
        drawXLabels()
        drawYLabels()
        
        
        var _:CAShapeLayer? = nil
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
        
        if let markerLine = lineMax {
            if let layer = markerLine.drawLine() {
                self.layer.addSublayer(layer)
                self.lineLayerStore.append(layer)
            }
        }
        if let markerLine = lineMin {
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
        _ = self.bounds.height
        _ = self.bounds.width
        
        let space = drawingArea.width / gridLinesX
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(gridColor.cgColor)
        var x:CGFloat = drawingArea.origin.x;
        var step:CGFloat = 0.0
        while step < gridLinesX {
            x +=  space
            context?.move(to: CGPoint(x: x, y: drawingArea.origin.y))
            context?.addLine(to: CGPoint(x: x, y: drawingArea.origin.y - drawingArea.height))
            step += 1
        }
        context?.strokePath()
    }
    
    
    
    /**
    * Draw y grid.
    */
    func drawYGrid() {
        
        let delta_h = drawingArea.height  / gridLinesY
        let context = UIGraphicsGetCurrentContext()
        var y:CGFloat = drawingArea.origin.y
        var step:CGFloat = 0.0
        while step < gridLinesY {

            y -= delta_h
            context?.move(to: CGPoint(x: drawingArea.origin.x, y: y))
            context?.addLine(to: CGPoint(x: drawingArea.origin.x + drawingArea.width, y: y))
            step += 1
            
        }
        context?.strokePath()
    }
    
    /**
    * Draw x and y axis.
    */
    func drawAxes() {
        if (!showAxes){
            return
        }
        let height = self.bounds.height
        _ = self.bounds.width
        
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(axesColor.cgColor)
        // draw x-axis
        context?.move(to: CGPoint(x: drawingArea.origin.x, y: drawingArea.origin.y))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x + drawingArea.width+5, y: drawingArea.origin.y))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x + drawingArea.width+5, y: drawingArea.origin.y-4))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x + drawingArea.width+5+10, y: drawingArea.origin.y))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x + drawingArea.width+5, y: drawingArea.origin.y+4))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x + drawingArea.width+5, y: drawingArea.origin.y-4))
        
        context?.strokePath()
        // draw y-axis
        context?.move(to: CGPoint(x: drawingArea.origin.x, y: drawingArea.origin.y))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x, y: marginTop - 5.0))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x-4.0, y: marginTop - 5.0))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x, y: marginTop - 5.0 - 10.0))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x+4.0, y: marginTop - 5.0))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x-4.0, y: marginTop - 5.0))
        context?.strokePath()
        
        let xAxeTitle = UILabel(frame: CGRect(x: pointZero.x, y: height - labelAxesSize.height, width: drawingArea.width, height: labelAxesSize.height))
        xAxeTitle.font = UIFont.italicSystemFont(ofSize: 12.0)
        xAxeTitle.textAlignment = .right
        xAxeTitle.backgroundColor = UIColor.clear
        xAxeTitle.text = titleForX
        self.addSubview(xAxeTitle)
        
        let yAxeTitle = UILabel(frame: CGRect(x: -labelAxesSize.height, y: pointZero.y, width: drawingArea.height, height:  labelAxesSize.height))
        yAxeTitle.font = UIFont.italicSystemFont(ofSize: 12.0)
        yAxeTitle.textAlignment = .right
        yAxeTitle.text = titleForY
        yAxeTitle.backgroundColor = UIColor.clear

        let yframe = yAxeTitle.frame
        yAxeTitle.layer.anchorPoint = CGPoint(x:(yframe.size.height / yframe.size.width * 0.5), y: -0.5) // Anchor points are in unit space
        yAxeTitle.frame = yframe; // Moving the anchor point moves the layer's position, this is a simple way to re-set
        yAxeTitle.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        
        self.addSubview(yAxeTitle)
        
    }
    
    func drawMarkers() {
        if (!showAxes){
            return
        }
        let height = self.bounds.height
        _ = self.bounds.width
        
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(axesColor.cgColor)
        // draw x-axis
        context?.move(to: CGPoint(x: drawingArea.origin.x, y: drawingArea.origin.y))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x + drawingArea.width+5, y: drawingArea.origin.y))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x + drawingArea.width+5, y: drawingArea.origin.y-4))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x + drawingArea.width+5+10, y: drawingArea.origin.y))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x + drawingArea.width+5, y: drawingArea.origin.y+4))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x + drawingArea.width+5, y: drawingArea.origin.y-4))
        
        context?.strokePath()
        // draw y-axis
        context?.move(to: CGPoint(x: drawingArea.origin.x, y: drawingArea.origin.y))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x, y: marginTop - 5.0))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x-4.0, y: marginTop - 5.0))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x, y: marginTop - 5.0 - 10.0))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x+4.0, y: marginTop - 5.0))
        context?.addLine(to: CGPoint(x: drawingArea.origin.x-4.0, y: marginTop - 5.0))
        context?.strokePath()
        
        let xAxeTitle = UILabel(frame: CGRect(x: pointZero.x, y: height - labelAxesSize.height, width: drawingArea.width, height: labelAxesSize.height))
        xAxeTitle.font = UIFont.italicSystemFont(ofSize: 12.0)
        xAxeTitle.textAlignment = .right
        xAxeTitle.backgroundColor = UIColor.clear
        xAxeTitle.text = titleForX
        self.addSubview(xAxeTitle)
        
        let yAxeTitle = UILabel(frame: CGRect(x: -labelAxesSize.height, y: pointZero.y, width: drawingArea.height, height:  labelAxesSize.height))
        yAxeTitle.font = UIFont.italicSystemFont(ofSize: 12.0)
        yAxeTitle.textAlignment = .right
        yAxeTitle.text = titleForY
        yAxeTitle.backgroundColor = UIColor.clear
       
        let yframe = yAxeTitle.frame
        yAxeTitle.layer.anchorPoint = CGPoint(x:(yframe.size.height / yframe.size.width * 0.5), y: -0.5) // Anchor points are in unit space
        yAxeTitle.frame = yframe; // Moving the anchor point moves the layer's position, this is a simple way to re-set
        yAxeTitle.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        
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
        let p = collectionLines[0].dots[0]

        offsetX = Offset(min:p.dot.x, max:p.dot.x )
        offsetY = Offset(min:p.dot.y, max:p.dot.y )
        
        for line in collectionLines {
            
            for curr:APChartPoint in line.dots {
                offsetX.updateMinMax(curr.dot.x)
                offsetY.updateMinMax(curr.dot.y)
            }
        }
        
        let x = offsetX.delta()/10
        offsetX.min -= x
        offsetX.max += x
        let y = offsetY.delta()/10
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
        
        let x_factor = drawingArea.width / ( offsetX.delta()) // - pointZero.x )
        let y_factor = drawingArea.height /  offsetY.delta()
        let factorPoint = CGPoint(x: x_factor, y: y_factor)
        
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
            let label = UILabel(frame: CGRect(x: pointZero.x-6.0, y: pointZero.y+12.0, width: pointZero.x-4.0-16.0, height: 16.0))
            label.backgroundColor = UIColor.clear
            label.font = UIFont.boldSystemFont(ofSize: 10)
            label.textAlignment = NSTextAlignment.left
            label.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 7 / 18)
            label.sizeToFit()
            label.text = "\(offsetX.min.round2dec())"
            self.addSubview(label)
        }
        
        let delta = drawingArea.width  / gridLinesX
        let xValue_delta = offsetX.delta()  / gridLinesX
        var x:CGFloat = pointZero.x
        var step:CGFloat = 0.0
        while step < gridLinesX {
            x += delta
            
            let label = UILabel(frame: CGRect(x: x-12.0, y: pointZero.y+12.0, width: pointZero.x-4.0-16.0, height: 16.0))
            label.font = UIFont.boldSystemFont(ofSize: 10)
            label.textAlignment = NSTextAlignment.left
            label.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 7 / 18)
            var textX = offsetX.min + xValue_delta*step
            label.text = "\(textX.round2dec())"
            label.sizeToFit()

            self.addSubview(label)
            step += 1
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
            let label = UILabel(frame: CGRect(x: 18.0, y:  pointZero.y-16.0, width: pointZero.x-4.0-16.0, height: 16.0))
            label.font = UIFont.systemFont(ofSize: 10)
            label.textAlignment = NSTextAlignment.right
            label.text = "\(offsetY.min.round2dec())"
            label.sizeToFit()
      
            self.addSubview(label)
        }
        
        let delta_h = drawingArea.height  / gridLinesY
        let yValue_delta = offsetY.delta()  / gridLinesY
        var y:CGFloat = pointZero.y
        var step:CGFloat = 0.0
        while step < gridLinesY {
            y -= delta_h
            
            let label = UILabel(frame: CGRect(x: 18.0, y: y-8.0, width: pointZero.x-4.0-16.0, height: 16.0))
            label.font = UIFont.systemFont(ofSize: 10)
            label.textAlignment = NSTextAlignment.right
            var textY = yValue_delta*step+offsetY.min
            label.text = "\(textY.round2dec())"
            label.sizeToFit()
      
            self.addSubview(label)
            step += 1
            
        }
    }
    
    
    func getClosetLineDot(_ selectedPoint:CGPoint) -> [String:APChartPoint]?{
        var delta:CGFloat = 100000.0
        var diff:CGFloat = 0.0
        var selectedDot:[String:APChartPoint] = [:]
        for line in collectionLines {
            delta = 5.0
            for (_,dot) in line.dots.enumerated(){
                dot.backgroundColor = dotsBackgroundColor
                
                diff  =  selectedPoint.distanceXFrom(dot.point)
                if delta > diff
                {
                    selectedDot[line.title] = dot
                    delta = diff
                }
            }
        }
        for (_, dot) in selectedDot {
            dot.backgroundColor = dotsBackgroundColor.lighterColorForColor()
        }
        return selectedDot
    }
    
    /**
    * Handle touch events.
    */
    func handleTouchEvents(_ touches: Set<NSObject>, withEvent event: UIEvent) {
        if (self.collectionLines.isEmpty) { return }
        
        let point: AnyObject! = touches.first
        let selectedPoint = point.location(in: self)
        
        let bpath = UIBezierPath()
        bpath.move(to: CGPoint(x: selectedPoint.x, y: marginTop))
        bpath.addLine(to: CGPoint(x: selectedPoint.x, y: pointZero.y))
        selectetedXlayer?.removeFromSuperlayer()
        
        selectetedXlayer = CAShapeLayer()
        selectetedXlayer!.frame = self.bounds
        selectetedXlayer!.path = bpath.cgPath
        selectetedXlayer!.strokeColor = UIColor.purple.cgColor //colors[lineIndex].CGColor
        selectetedXlayer!.fillColor = nil
        selectetedXlayer!.lineWidth = 1.0
        self.layer.addSublayer(selectetedXlayer!)
        
        
        if let closestDots = getClosetLineDot(selectedPoint) {
            delegate?.didSelectNearDataPoint(closestDots)
        }
        
    }
    
    
    /**
    * Listen on touch end event.
    */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (event != nil) {
            handleTouchEvents(touches, withEvent: event!)
        }
    }
    
    /**
    * Listen on touch move event
    */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (event != nil) {
            handleTouchEvents(touches, withEvent: event!)
        }
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
    func updateMinMax(_ value:CGFloat){
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
