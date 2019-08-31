//
//  CirclerView.swift
//  NotesThing
//
//  Created by Alex Gajewski on 8/28/19.
//  Copyright © 2019 Alex Gajewski. All rights reserved.
//

import UIKit
import WebKit

class CirclerView: UIView {

    var path = CGMutablePath()
    var displayPath: CGPath? = nil
    var webView: WKWebView? = nil
    var ended = false
    let bigDelta: CGFloat = 20

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.addPath(path)
        if !ended {
            context.strokePath()
        } else {
            context.fillPath()
        }
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
        ended = false
        path = CGMutablePath()
        path.move(to: touch.location(in: self))
        self.setNeedsDisplay()
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
        path.addLine(to: location)
        self.setNeedsDisplay()
    }
    
    func snapshotCompletion(_ image: UIImage?, _ error: Error?) {
        let box = path.boundingBox
        if box.width < 10 || box.height < 10 {
            return
        }
        let bigBox = CGRect(x: box.minX - bigDelta, y: box.minY - bigDelta, width: box.width + 2 * bigDelta, height: box.height + 2 * bigDelta)
        let scaledBox = CGRect(x: 2 * box.minX, y: 2 * box.minY, width: 2 * box.width, height: 2 * box.height)
        let croppedImage = image!.cgImage!.cropping(to: scaledBox)!
        let uiImage = UIImage(cgImage: croppedImage)
        // let imageView = UIImageView(image: UIImage(cgImage: croppedImage))
 
        // let hoverView = UIView()
        // hoverView.frame = convert(bigBox, to: superview!.superview)

        // imageView.frame = convert(box, to: hoverView)
        // imageView.contentMode = .scaleAspectFit
        // imageView.isOpaque = false
        // hoverView.addSubview(imageView)

        let fixedPath = FixedPath()
        fixedPath.frame = convert(bigBox, to: superview!.superview)
        fixedPath.image = uiImage
        fixedPath.interior = convert(box, to: fixedPath)
        var transform = CGAffineTransform(translationX: -bigBox.minX, y: -bigBox.minY)
        fixedPath.setPath(path: path.copy(using: &transform), displayPath: displayPath!.copy(using: &transform))
        // hoverView.addSubview(fixedPath)

        superview!.superview!.addSubview(fixedPath)
    }

    func endStroke(touch: UITouch) {
        let location = touch.location(in: self)
        path.addLine(to: location)
        displayPath = path.copy()
        path.closeSubpath()
        ended = true
        self.setNeedsDisplay()
        webView!.takeSnapshot(with: nil, completionHandler: snapshotCompletion)
        path = CGMutablePath()
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