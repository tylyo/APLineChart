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
        var line = APChartLine(chartView: chart, title: "prova", lineWidth: 2.0, lineColor: UIColor.purpleColor())
        var x:CGFloat = 1
        for i:Int in 0...20{
            x = x+1 + CGFloat(arc4random_uniform(10))
            line.addPoint( CGPoint(x: x, y: CGFloat(35 + arc4random_uniform(200))))
            
        }
        chart.addLine(line)
        chart.setNeedsDisplay()

    }

    func didSelectNearDataPoint(selectedDots: [String : APChartPoint]) {
        var txt = ""
        for (title,value) in selectedDots {
            txt = "\(txt)\(title): \(value.dot)\n"
        }
        lblPoint.text = txt
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if let chartV = chart {
            chartV.setNeedsDisplay()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

