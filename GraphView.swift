//
//  GraphView.swift
//  GraphTest
//
//  Created by PanaCloud on 6/24/15.
//  Copyright (c) 2015 PanaCloud. All rights reserved.
//

import UIKit
import Foundation
@IBDesignable class GraphView: UIView {
    
    var graphPoints:[Float] = []
    var points:[CGPoint] = []
    var month = 0
    var interval:Interval = Interval.lastWeek
    
    override func drawRect(rect: CGRect) {
        print(__FUNCTION__)
        
        //Check whether there exists atleast one non-nil point
        if Arithmetic.getMinElement(array: graphPoints) != nil  {
            
            
            //Remove any previously added layers to avoid overlapped drawing
            layer.sublayers = nil
            
            
            let width = rect.width - 5
            let height = rect.height
            let context = UIGraphicsGetCurrentContext()
            
            CGContextDrawPath(context, CGPathDrawingMode.Fill)
            
            //To calculate x coordinate
            let margin:CGFloat = 35
            
            let columnXPoint = {(column:Float)->CGFloat in
                var dividerInterval:CGFloat = 0
                if self.interval.rawValue == 0 {
                    dividerInterval = 7
                } else if self.interval.rawValue == 1 {
                    dividerInterval = 30
                } else if self.interval.rawValue == 2 {
                    dividerInterval = 90
                } else {
                    dividerInterval = 365
                }
                let space = (width-margin*2-4) / dividerInterval
                var x:CGFloat = CGFloat(column)*space
                x += margin + 8
                return x
            }
            
            //To calculate y coordinate
            let topBorder:CGFloat = (height-25 - CGFloat(4*Int(height/5)))
            let bottomBorder:CGFloat = height - (height-25 - CGFloat(0*Int(height/5)))
            
            let graphHeight = height - topBorder - bottomBorder
            let maxValue = graphPoints.maxElement()!
            
            
            
            let columnYPoint = {(graphPoint:Float)->CGFloat in
                //Saving the original state of the points array, incase scaling is needed.
                let tempArray = self.graphPoints
                
                //Check for the variation in weight, If none, Scale up
                if !(Arithmetic.variationInWeight(arrayToCheck: self.graphPoints)) {
                    //Scale up the array
                    Arithmetic.scaleUp(arrayToScale: &self.graphPoints)
                }
                //Normalize the point in the range of 0-1 before drawing.
                var y:CGFloat = Arithmetic.normalize(x: graphPoint,array: self.graphPoints)
                
                y = graphHeight  + topBorder - (y * graphHeight)
                
                //Restoring the original state of the array
                self.graphPoints = tempArray
                return y
            }
            
            //path
            let graphPath = UIBezierPath()
            
            //Move to the very first point of the graph
            //If the first point is nil then skip until the next non-nil point is found
            if !(graphPoints[0] == 0) {
                graphPath.moveToPoint(CGPoint(x: columnXPoint(0), y: columnYPoint(graphPoints[0])))
            } else {
                for i in 1..<graphPoints.count {
                    if graphPoints[i] == 0 {
                        continue
                    } else {
                        graphPath.moveToPoint(CGPoint(x: columnXPoint(Float(i)), y: columnYPoint(graphPoints[i])))
                        break
                    }
                }
            }
            
            //add points for each item in the graphPoints array
            //at the correct (x,y) for the point
            
            for i in 1..<graphPoints.count {
                //If the weight for the given day is nil
                if graphPoints[i] == 0 {
                    continue
                }
                let nextPoint = CGPoint(x: columnXPoint(Float(i)) , y: columnYPoint(graphPoints[i]))
                graphPath.addLineToPoint(nextPoint)
            }
            
            let animatedPath = CAShapeLayer()
            //Setting layer properties
            animatedPath.path = graphPath.CGPath
            animatedPath.strokeColor = UIColor.whiteColor().CGColor
            animatedPath.fillColor = UIColor.clearColor().CGColor
            animatedPath.lineWidth = 2.0
            animatedPath.lineCap = kCALineCapRound
            animatedPath.lineJoin = kCALineJoinRound
            self.layer.addSublayer(animatedPath)
            
            //Setting layer animation(s)
            let animateStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
            animateStrokeEnd.duration = 1.0
            animateStrokeEnd.fromValue = 0.0
            animateStrokeEnd.toValue = 1.0
            animatedPath.addAnimation(animateStrokeEnd, forKey: nil)
            
           
            //Drawing the rounded points
            for i in 0..<graphPoints.count {
                //If the weight for the given day is nil
                var point = CGPoint(x: columnXPoint(Float(i)), y: columnYPoint(graphPoints[i]))
                points.append(point)
                
                //If the weight for the given day is nil
                if graphPoints[i] == 0 {
                    continue
                }
                
                //Adjusting the point
                point.x -= 3.5
                point.y -= 3.5
                let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: 3.5, height: 3.5)))
                
                //Setting layer properties
                let animatedPoints = CAShapeLayer()
                animatedPoints.path = circle.CGPath
                animatedPoints.strokeColor = UIColor.whiteColor().CGColor
                animatedPoints.fillColor = UIColor.whiteColor().CGColor
                animatedPoints.lineWidth = 8.0
                self.layer.insertSublayer(animatedPoints, above: animatedPath)
                
            } 
            
            //Hollowfying the rounded points
             for i in 0..<graphPoints.count {
                
                //If the weight for the given day is null
                if graphPoints[i] == 0 {
                    //points.append(CGPoint(x: 0, y: 0))
                    continue
                }
                
                var point = CGPoint(x: columnXPoint(Float(i)), y: columnYPoint(graphPoints[i]))
                point.x -= 3.5
                point.y -= 3.5
                
                //Setting up the layer properties
                let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: 3.5, height: 3.5)))
                let animatedPoints = CAShapeLayer()
                animatedPoints.path = circle.CGPath
                animatedPoints.strokeColor = UIColor(red: 24/255.0, green: 163/255.0, blue: 252/255.0, alpha: 1.0).CGColor
                animatedPoints.fillColor = UIColor(red: 24/255.0, green: 163/255.0, blue: 252/255.0, alpha: 1.0).CGColor
                animatedPoints.lineWidth = 2.0
                self.layer.addSublayer(animatedPoints)
                
            }
        }
        
        //Setting neccessary properties
        let context = UIGraphicsGetCurrentContext()
        CGContextDrawPath(context, CGPathDrawingMode.Fill)
        let width = rect.width - 5
        let height = rect.height
        let margin:CGFloat = 35
        
        //Drawing axes/divisions
        drawDivisions(context: context!, width: width, height: height, margin: margin)
        
        //Adding labels
        addLabels(height: height,width: width,margin: margin)
        
    }
    
    func addLabels(height height:CGFloat,width:CGFloat,margin:CGFloat) {
        
        //Saving the original state of the points array
        let tempArray = graphPoints
        
        //Check whether there exists atleast one non-nil point
        if Arithmetic.getMinElement(array: graphPoints) != nil {
            
            //Check for the variation in weight, If none, Scale up
            if !(Arithmetic.variationInWeight(arrayToCheck: self.graphPoints)) {
                //Scale up the array
                Arithmetic.scaleUp(arrayToScale: &graphPoints)
            }
            
            let maxValue = graphPoints.maxElement()! //+ 10
            let minValue = Arithmetic.getMinElement(array:graphPoints) //- 10
            let range = maxValue - minValue!
            let division = range / 4
            
            
            
            //Adding labels
            for i in 0...4 {
                
                let label = UILabel(frame: CGRectMake(margin - 35.0, (height-30) - CGFloat(i*Int(height/4.8)), 40, 10))
                
                label.text = "\(Double(minValue! + (division*Float(i))).roundToPlaces(1))"
                label.font = UIFont.systemFontOfSize(12)
                label.textAlignment = NSTextAlignment.Center
                label.textColor = UIColor.whiteColor()
                self.addSubview(label)
                
                
            }
            
            
            
        }
        //Adding week labels - Un comment the following if you want to show week labels
        /*let weeks = ["Week1","Week2","Week3","Week4"]
        for i in 0...3 {
            
            let weekLbl = UILabel(frame: CGRectMake((width/5) * CGFloat(i+1), height - 28, 40, 30))
            
            weekLbl.text = weeks[i]
            weekLbl.font = UIFont.systemFontOfSize(12)
            weekLbl.textColor = UIColor.whiteColor()
            self.addSubview(weekLbl)
            
            let rounded = round(33.0 * 10) / 10
            
        }
        
        //Adding month label
        let months = ["January","Feburary","March","April","May","June","July","August","September","October","November","December"]
        let monthLbl = UILabel(frame: CGRectMake((width/5) * CGFloat(4), -10, 70, 30))
        monthLbl.text = months[month-1]
        monthLbl.font = UIFont.systemFontOfSize(12)
        monthLbl.textColor = UIColor.whiteColor()
        self.addSubview(monthLbl) // */
        
        //Restoring the original state of the points array
        graphPoints = tempArray
    }
    
    func drawDivisions(context context:CGContext,width:CGFloat,height:CGFloat,margin:CGFloat) {
        
        let linePath = UIBezierPath()
        
        //To draw horizontal division(s)
        for i in 0..<1 {
            
            linePath.moveToPoint(CGPoint(x: margin , y: (height-20) - CGFloat(i*Int(height/5))))
            linePath.addLineToPoint(CGPoint(x:width, y: (height-20) - CGFloat(i*Int(height/5))))
            
        }
        //Reverse of the above (work around for now - could be better)
        for i in 4..<5 {
            
            linePath.moveToPoint(CGPoint(x: margin , y: (height-33) - CGFloat(i*Int(height/5))))
            linePath.addLineToPoint(CGPoint(x:width, y: (height-33) - CGFloat(i*Int(height/5))))
            
        }
        
        //To Draw vertical divisions
        
        switch interval {
        case .lastWeek:
            for var i:CGFloat = 0.0; i <= 6.0; i++ {
            
                linePath.moveToPoint(CGPoint(x: margin + (i*(width/7)) , y: (height-33) - CGFloat(4*Int(height/5))))
                linePath.addLineToPoint(CGPoint(x: margin + (i*(width/7)), y: height-20))
                
            }
        case .lastMonth:
            for var i:CGFloat = 0.0; i < 4.0; i++ {
                linePath.moveToPoint(CGPoint(x: margin + (i*(width/4)) , y: (height-33) - CGFloat(4*Int(height/5))))
                linePath.addLineToPoint(CGPoint(x: margin + (i*(width/4)), y: height-20))
            }
            
        case .lastQuarter:
            for var i:CGFloat = 0.0; i < 3.0; i++ {
                linePath.moveToPoint(CGPoint(x: margin + (i*(width/3)) , y: (height-33) - CGFloat(4*Int(height/5))))
                linePath.addLineToPoint(CGPoint(x: margin + (i*(width/3)), y: height-20))
            }
        case .lastYear:
            for var i:CGFloat = 0.0; i < 12.0; i++ {
                linePath.moveToPoint(CGPoint(x: margin + (i*(width/12)) , y: (height-33) - CGFloat(4*Int(height/5))))
                linePath.addLineToPoint(CGPoint(x: margin + (i*(width/12)), y: height-20))
            }
        }
        
        
        
        //To draw y-axis - Un comment the follwing if you want to draw y- axis
        /*linePath.moveToPoint(CGPoint(x: margin , y: 0))
        linePath.addLineToPoint(CGPoint(x: margin, y: height-25))
        */
        
        UIColor.whiteColor().setStroke()
        linePath.lineWidth = 0.35
        linePath.stroke()
        
        
    }
    
}

class GraphObject {
    
}

class Arithmetic {
    
    //Finds the minimum element in the collection, exculding all zeroes.
    class func getMinElement(array array:[Float])-> Float? {
        var lowestElement:Float?
        
        for item in array{
            if(item==0){
                continue
            }
            else{
                lowestElement=item
                break
            }
        }
        if  lowestElement != nil {
            for item in array {
                if item < lowestElement {
                    if item == 0 {
                        continue
                    }
                    lowestElement = item
                }
            }
            return lowestElement!
        } else {
            return lowestElement
        }
    }
    
    //Rounds to nearest tens
    class func roundToTens(x x:Float) -> Float {
        return Float(round(10*x)/10)
    }
    
    //Normalizes the values in the range 0-1
    class func normalize(x x:Float,array:[Float])->CGFloat {
        if (array.maxElement()!-self.getMinElement(array: array)!) != 0 {
            let normalizedValue:CGFloat = CGFloat((x - Arithmetic.getMinElement(array: array)!) / (array.maxElement()! - Arithmetic.getMinElement(array: array)!))
            return normalizedValue
        } else {
            let normalizedValue:CGFloat = CGFloat((x - Arithmetic.getMinElement(array: array)!) / 1.0)
            return normalizedValue
        }
    }
    
    //Eliminates zeroes from the collection
    class func eliminateZeroes(arrayToModify arrayToModify:[Float])->[Float] {
        var modifiedArray:[Float] = []
        for element in arrayToModify {
            if element != 0 {
                modifiedArray.append(element)
            }
        }
        return modifiedArray
    }
    
    //Checks whether variation exists or not
    class func variationInWeight(arrayToCheck arrayToCheck:[Float])->Bool {
        var flag=false
        var lastWeight:Float=0
        if arrayToCheck.count != 0 {
            var modifiedArray:[Float] = Arithmetic.eliminateZeroes(arrayToModify: arrayToCheck)
            lastWeight = modifiedArray[0]
            for weight in modifiedArray {
                if  (lastWeight != weight) {
                    return true
                }
                
            }
        }
        return false
    }
    
    //Scales up the given collection
    class func scaleUp(inout arrayToScale arrayToScale:[Float]){
        
        for var i=0 ; i<arrayToScale.count ; i++ {
            if arrayToScale[i] != 0 {
                //Check whether subtraction from the number results in a negative, if yes then compensate for it.
                //Else scale both sides
                if arrayToScale[i]-5 <= 0 {
                    
                    arrayToScale.insert(arrayToScale[i]+5, atIndex: i)
                    arrayToScale.insert(arrayToScale[i+1]+10, atIndex: i+2)
                    
                } else {
                    arrayToScale.insert(arrayToScale[i]-5, atIndex: i)
                    arrayToScale.insert(arrayToScale[i+1]+5, atIndex: i+2)
                }
                break
            }
        }
        return
    }
    
    
    
}

extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}

