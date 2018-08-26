//
//  ViewController.swift
//  APLineChart
//
//  Created by Attilio Patania on 23/03/15.
//  Copyright (c) 2015 Attilio Patania. All rights reserved.
//

import UIKit

class ViewController: UIViewController,APChartViewDelegate {

    @IBOutlet var chart: APChartView!
    @IBOutlet var lblPoint: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        chart.delegate = self
        
        createLine()
        
    }

    @IBAction func createLine(){
        chart.collectionLines = []
        let line = APChartLine(chartView: chart, title: "prova", lineWidth: 2.0, lineColor: UIColor.purple)
        var x:CGFloat = 1
        for _:Int in 0...20{
            x = x+1 + CGFloat(arc4random_uniform(10))
            line.addPoint( CGPoint(x: x, y: CGFloat(35 + arc4random_uniform(200))))
            
        }
        chart.addLine(line)
        
        
        self.chart.addMarkerLine("x marker", x: 85.0 )
        self.chart.addMarkerLine("y marker", y: 120.0 )
        
        chart.setNeedsDisplay()

    }

    func didSelectNearDataPoint(_ selectedDots: [String : APChartPoint]) {
        var txt = ""
        for (title,value) in selectedDots {
            txt = "\(txt)\(title): \(value.dot)\n"
        }
        lblPoint.text = txt
    }
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if let chartV = chart {
            chartV.setNeedsDisplay()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

