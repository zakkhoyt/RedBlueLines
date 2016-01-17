//
//  RBView.swift
//  RedBlueLines
//
//  Created by Zakk Hoyt on 1/17/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//

import UIKit


enum RBLineType: UInt {
    case Drawing = 0
    case White
    case Black
}


struct RBLine {
    
    var startPoint: CGPoint
    var endPoint: CGPoint
    var type: RBLineType
    var color: UIColor
    
    init(){
        startPoint = CGPointZero
        endPoint = CGPointZero
        type = .Drawing
        color = UIColor.redColor()
    }
}


@IBDesignable class RBView: UIView {

    var currentLineColor = UIColor.whiteColor()
    var currentLineStartPoint = CGPointZero
    var currentLineWhite: Bool = false
    var currentLine: RBLine? = nil
    var currentLineValid: Bool = true
    var lines: [RBLine] = []


    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.CGColor
        }
    }
    
    
    override func prepareForInterfaceBuilder() {
        setNeedsDisplay()  // Causes drawRect to be called soon
    }
    
    
    override func drawRect(rect: CGRect) {
        ib()
        drawLines()
    }
    
    
    func ib() {
        layer.borderColor = borderColor?.CGColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        
    }
    
    func drawLines() {
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 2.0)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        // Draw current line
        if let currentLine = currentLine {
            if currentLine.startPoint == CGPointZero || currentLine.endPoint == CGPointZero {
                // don't draw this. There isn't enough info
            } else {
                let components: [CGFloat] = currentLine.type == .White ? [1.0, 1.0, 1.0, 1.0] : [0.0, 0.0, 0.0, 1.0]
                let color = CGColorCreate(colorSpace, components)
                CGContextSetStrokeColorWithColor(context, color)
                CGContextMoveToPoint(context, currentLine.startPoint.x, currentLine.startPoint.y)
                CGContextAddLineToPoint(context, currentLine.endPoint.x, currentLine.endPoint.y)
                CGContextStrokePath(context)
            }
        }
        
        // past lines
        for line in lines {
            let components: [CGFloat] = line.type == .White ? [1.0, 1.0, 1.0, 1.0] : [0.0, 0.0, 0.0, 1.0]
            let color = CGColorCreate(colorSpace, components)
            CGContextSetStrokeColorWithColor(context, color)
            CGContextMoveToPoint(context, line.startPoint.x, line.startPoint.y)
            CGContextAddLineToPoint(context, line.endPoint.x, line.endPoint.y)
            CGContextStrokePath(context)
        }
        
        // background (valid)
        backgroundColor = currentLineValid ? UIColor.greenColor() : UIColor.redColor()
    }
    
    
    func validateLines() {
        if lines.count >= 3 {

            
            if let A = currentLine {
                
                let x1A: CGFloat = min(A.startPoint.x, A.endPoint.x)
                let x2A: CGFloat = x1A == A.startPoint.x ? A.endPoint.x : A.startPoint.x
                
                let y1A: CGFloat = min(A.startPoint.y, A.endPoint.y)
                let y2A: CGFloat = y1A == A.startPoint.y ? A.endPoint.y : A.startPoint.y
                
                for B in lines {
                    let x1B: CGFloat = min(B.startPoint.x, B.endPoint.x)
                    let x2B: CGFloat = x1B == B.startPoint.x ? B.endPoint.x : B.startPoint.x
                    
                    let y1B: CGFloat = min(B.startPoint.y, B.endPoint.y)
                    let y2B: CGFloat = y1B == B.startPoint.y ? B.endPoint.y : B.startPoint.y

                    //                ( x1B ≤ x1A ≤ x2B OR x1B ≤ x2A ≤ x2B )
                    //
                    //                AND
                    //
                    //                ( y1B ≤ y1A ≤ y2B OR y1B ≤ y2A ≤ y2B )
                    
                    
                    if (x1B <= x1A && x1A <= x2B || x1B <= x2A && x2A <= x2B) && ( y1B <= y1A && y1A <= y2B || y1B <= y2A && y2A <= y2B ) {
                        // Lines intersect 
                        currentLineValid = false
                        return
                    }
                }
                currentLineValid = true
                return
            }
            currentLineValid = false
            
        } else {
            currentLineValid = true
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        currentLine = RBLine()
        // Color
        if currentLineWhite {
            currentLine?.type = .White
        } else {
            currentLine?.type = .Black
        }
        // Start point
        if currentLineStartPoint == CGPointZero {
            for touch in touches {
                let point = touch.locationInView(self)
                currentLine?.startPoint = point
            }
            
        } else {
            currentLine?.startPoint = currentLineStartPoint
        }

        setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let point = touch.locationInView(self)
            currentLine?.endPoint = point
        }
        validateLines()
        setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let point = touch.locationInView(self)
            currentLine?.endPoint = point
        }
    
        if let currentLine = currentLine {
            if currentLineValid {
                lines.append(currentLine)
                currentLineStartPoint = currentLine.endPoint
                currentLineWhite = !currentLineWhite
            } else {
                self.currentLine = nil
            }
        }
        
        validateLines()
        setNeedsDisplay()
        
        backgroundColor = UIColor.lightGrayColor()
        
    }
    
    
}
