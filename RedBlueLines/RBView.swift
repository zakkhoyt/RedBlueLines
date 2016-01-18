//
//  RBView.swift
//  RedBlueLines
//
//  Created by Zakk Hoyt on 1/17/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//
//  Inspired by reddit post: https://www.reddit.com/r/math/comments/41cmkx/an_interesting_geometric_lines_game/

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
        
        // paste lines
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
        // only check after we have 3 or more lines to compare against
        if lines.count > 3 {
            if let cl = currentLine {
                for i in 0..<lines.count - 1 {
                    let l = lines[i]
                    if doIntersect(cl.startPoint, q1: cl.endPoint, p2: l.startPoint, q2: l.endPoint) {
                        currentLineValid = false
                        return
                    }
                }
                currentLineValid = true
                return
            }
            
            // Default for 3 or more lines
            currentLineValid = false
        } else {
            // Default for less than 3 lines
            currentLineValid = true
        }
    }
    
    
    
    // Given three colinear points p, q, r, the function checks if
    // point q lies on line segment 'pr'

    func onSegment(p: CGPoint, q: CGPoint, r: CGPoint) -> Bool {
        if (q.x <= max(p.x, r.x) && q.x >= min(p.x, r.x) && q.y <= max(p.y, r.y) && q.y >= min(p.y, r.y)) {
            return true
        } else {
            return false
        }
    }


    // To find orientation of ordered triplet (p, q, r).
    // The function returns following values
    // 0 --> p, q and r are colinear
    // 1 --> Clockwise
    // 2 --> Counterclockwise
    
    func orientation(p: CGPoint, q: CGPoint, r: CGPoint) -> UInt {
        let val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)
        if val == 0 {
            return 0
        } else {
            return val > 0 ? 1 : 2
        }
    }
    
    // The main function that returns true if line segment 'p1q1'
    // and 'p2q2' intersect.
    func doIntersect(p1: CGPoint, q1: CGPoint, p2: CGPoint, q2: CGPoint) -> Bool {
        // Find the four orientations needed for general and
        // special cases
        let o1 = orientation(p1, q: q1, r: p2)
        let o2 = orientation(p1, q: q1, r: q2)
        let o3 = orientation(p2, q: q2, r: p1)
        let o4 = orientation(p2, q: q2, r: q1)
        
        // General case
        if o1 != o2 && o3 != o4 {
            return true
        }
        
        // Special Cases
        // p1, q1 and p2 are colinear and p2 lies on segment p1q1
        if (o1 == 0 && onSegment(p1, q: p2, r: q1)) {
            return true
        }
        
        // p1, q1 and p2 are colinear and q2 lies on segment p1q1
        if (o2 == 0 && onSegment(p1, q: q2, r: q1)) {
            return true
        }
        
        // p2, q2 and p1 are colinear and p1 lies on segment p2q2
        if (o3 == 0 && onSegment(p2, q: p1, r: q2)){
            return true
        }
        
        // p2, q2 and q1 are colinear and q1 lies on segment p2q2
        if (o4 == 0 && onSegment(p2, q: q1, r: q2)){
            return true
        }
        
        // Doesn't fall in any of the above cases
        return false
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
