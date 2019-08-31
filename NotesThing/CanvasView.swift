//
//  selfView.swift
//  NotesThing
//
//  Created by Alex Gajewski on 8/26/19.
//  Copyright © 2019 Alex Gajewski. All rights reserved.
//

import UIKit

enum ToolType {
    case pen
    case eraser
}

class CanvasView: UIView {

    var path = CGMutablePath()
    var finishedPaths = [CGPath]()
    var strokedPaths = [CGPath]()
    var pathsToErase = [CGPath]()
    var currTool = ToolType.pen
    var nextTool = ToolType.pen
    var drawing = false
    var eraserLocation: CGPoint? = nil
    var eraserSize: CGFloat = 30
    
    override func draw(_ rect: CGRect) {
        drawPath(path: path)
        for finishedPath in finishedPaths {
            drawPath(path: finishedPath)
        }
        for pathToErase in pathsToErase {
            drawPath(path: pathToErase, erase: true)
        }
        if eraserLocation != nil {
            drawEraser()
        }
    }
    
    func drawEraser() {
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.black.withAlphaComponent(0.2).cgColor)
        context.fillEllipse(in: CGRect(x: eraserLocation!.x - eraserSize / 2, y: eraserLocation!.y - eraserSize / 2, width: eraserSize, height: eraserSize))
    }

    func drawPath(path: CGPath, erase: Bool = false) {
        let context = UIGraphicsGetCurrentContext()!
        context.addPath(path)
        context.setLineWidth(2)
        context.setLineCap(.round)
        if !erase {
            context.setStrokeColor(UIColor.black.cgColor)
        } else {
            context.setStrokeColor(UIColor.black.withAlphaComponent(0.2).cgColor)
        }
        context.strokePath()
    }
    
    /* func lastRect(prev: CGPoint, curr: CGPoint) -> CGRect {
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
     } */
    
    func eraseStrokes(_ touch: UITouch) {
        var i = strokedPaths.count
        for strokedPath in strokedPaths.reversed() {
            i -= 1
            if strokedPath.contains(touch.location(in: self)) {
                strokedPaths.remove(at: i)
                let finishedPath = finishedPaths.remove(at: i)
                pathsToErase.append(finishedPath)
                setNeedsDisplay()
            }
        }
    }

    func startStroke(touch: UITouch) {
        drawing = true
        if currTool == .pen {
            path = CGMutablePath()
            path.move(to: touch.location(in: self))
        } else if currTool == .eraser {
            eraseStrokes(touch)
            eraserLocation = touch.location(in: self)
            setNeedsDisplay()
        }
    }
    
    func updateStroke(touch: UITouch) {
        if currTool == .pen {
            let location = touch.location(in: self)
            path.addLine(to: location)
            setNeedsDisplay()
        } else if currTool == .eraser {
            eraseStrokes(touch)
            eraserLocation = touch.location(in: self)
            setNeedsDisplay()
        }
    }
    
    func endStroke(touch: UITouch) {
        drawing = false
        if currTool == .pen {
            let location = touch.location(in: self)
            path.addLine(to: location)
            finishedPaths.append(path.copy()!)
            strokedPaths.append(path.copy(strokingWithWidth: eraserSize, lineCap: .round, lineJoin: .round, miterLimit: 2))
            path = CGMutablePath()
            setNeedsDisplay()
        } else if currTool == .eraser {
            pathsToErase.removeAll()
            eraserLocation = nil
            setNeedsDisplay()
        }
        updateTool()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        self.startStroke(touch: touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        for subTouch in event!.coalescedTouches(for: touch)! {
            self.updateStroke(touch: subTouch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        self.endStroke(touch: touch)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        self.endStroke(touch: touch)
    }
    
    func setPen() {
        nextTool = .pen
        updateTool()
    }
    
    func setEraser() {
        nextTool = .eraser
        updateTool()
    }
    
    func updateTool() {
        if !drawing {
            currTool = nextTool
        }
    }
}
