# APLineChart
IOS Line Chart

It's a fully customizable Line chart using Interface Builder. I hope that it could be useful in your app.
Any feedback are welcome

## Usage
What you have to do is to include APChartView directory in your project.

Than you have to use APChartView as Class used within Custom Class of the View that will use the Control.
Next you have to link it to a class attribute, like you usually should do. 
 
than you are free to customize it and to see the updates in realtime.

In order to add one or more line you have to simple follow these instructions:

1. create a line:
```swift
var line = APChartLine(chartView: chart, title: "prova", lineWidth: 2.0, lineColor: UIColor.purpleColor())
```

2. add point to this line:
```swift
line.addPoint( CGPoint(x: x, y: y))
```

3. and add the line to the chart:
```swift
chart.addLine(line)
```

## Customizations

WIP

