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
        // Do any additional setup after loading the view, typically from a nib.
        chart.delegate = self
        var line = APChartLine(chartView: chart, title: "prova", lineWidth: 2.0, lineColor: UIColor.purpleColor())
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
        
        chart.addLine(line)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didSelectDataPoint(selectedDots: [String : APChartPoint]) {
        
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if let chartV = chart {
            chartV.setNeedsDisplay()
        }
    }

}

