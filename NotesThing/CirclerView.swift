//
//  CirclerView.swift
//  NotesThing
//
//  Created by Alex Gajewski on 8/28/19.
//  Copyright © 2019 Alex Gajewski. All rights reserved.
//

import UIKit

class CirclerView: UIView {

    var currStroke = [CGPoint]()

    override func draw(_ rect: CGRect) {
        drawStroke(stroke: currStroke)
    }
    
    func drawStroke(stroke: [CGPoint]) {
        if stroke.count < 2 {
            return
        }
        let context = UIGraphicsGetCurrentContext()!
        for i in 1..<stroke.count {
            context.beginPath()
            context.move(to: stroke[i-1])
            context.addLine(to: stroke[i])
            context.setLineWidth(2)
            context.setLineCap(.round)
            context.strokePath()
        }
    }
    
    
    func startStroke(touch: UITouch) {
        currStroke = [touch.location(in: self)]
    }
    
    func lastRect(prev: CGPoint, curr: CGPoint) -> CGRect {
        let prevX = prev.x
        let prevY = prev.y
        let currX = curr.x
        let currY = curr.y
        let minX = min(prevX, currX) - 5
        let maxX = max(prevX, currX) + 5
        let minY = min(prevY, currY) - 5
        let maxY = max(prevY, currY) + 5
        let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        return rect
    }
    
    func updateStroke(touch: UITouch) {
        let location = touch.location(in: self)
        currStroke.append(location)
        self.setNeedsDisplay(lastRect(prev: currStroke[currStroke.count - 2], curr: location))
    }
    
    func endStroke(touch: UITouch) {
        currStroke = []
        self.setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if touch.type != .pencil {
            return
        }
        self.startStroke(touch: touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if touch.type != .pencil {
            return
        }
        for subTouch in event!.coalescedTouches(for: touch)! {
            self.updateStroke(touch: subTouch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if touch.type != .pencil {
            return
        }
        self.endStroke(touch: touch)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if touch.type != .pencil {
            return
        }
        self.endStroke(touch: touch)
    }
    
}
