//
//  FixedPath.swift
//  NotesThing
//
//  Created by Alex Gajewski on 8/30/19.
//  Copyright © 2019 Alex Gajewski. All rights reserved.
//

import UIKit

class FixedPath: UIView {

    var path: CGPath? = nil
    var displayPath: CGPath? = nil
    var image: UIImage? = nil
    var interior: CGRect? = nil
    var imageMask: CGImage? = nil
    let shadowPixels: CGFloat = 5
    var initCenter: CGPoint? = nil
    var onCanvas = false
    var moving = false

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        // context.saveGState()
        if moving {
            context.setShadow(offset: CGSize(width: 0, height: 0), blur: 15.0, color: UIColor.gray.cgColor)
        }
        // let shadowX = 1 - shadowPixels / frame.width
        // let shadowY = 1 - shadowPixels / frame.height
        // let shrink = CGAffineTransform(a: shadowX, b: 0, c: 0, d: shadowY, tx: (1 - shadowX) / 2 * frame.width, ty: (1 - shadowY) / 2 * frame.height)
        // context.concatenate(shrink)
        context.addPath(path!)
        context.setFillColor(UIColor.black.cgColor)
        context.fillPath()
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 5.0, color: nil)
        context.clip(to: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), mask: imageMask!)
        image!.draw(in: interior!)
        context.resetClip()
        context.addPath(path!)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(5)
        context.setLineCap(.round)
        context.strokePath()
        // UIImage(cgImage: imageMask!).draw(in: interior!)
    }
    
    func setPath(path: CGPath?, displayPath: CGPath?) {
        self.path = path
        self.displayPath = displayPath
        backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()!
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: frame.height)
        context.concatenate(flipVertical)
        
        context.addPath(path!)
        context.setFillColor(UIColor.black.cgColor)
        context.fillPath()
        imageMask = context.makeImage()!
        UIGraphicsEndImageContext()
        
        setNeedsDisplay()
    }
    
    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        let controller = (window!.rootViewController as! ViewController)
        
        if gestureRecognizer.state == .began {
            initCenter = center
            controller.animateExpandScrollView()
            
            moving = true
            setNeedsDisplay()
            return
        }
        
        if gestureRecognizer.state == .ended {
            moving = false
            setNeedsDisplay()
        }
        
        let translation = gestureRecognizer.translation(in: self)
        center = CGPoint(x: initCenter!.x + translation.x, y: initCenter!.y + translation.y)
        let testCenter = superview!.convert(center, to: controller.canvasScroll)
        
        if gestureRecognizer.state == .ended && controller.canvasScroll.point(inside: testCenter, with: nil) && !onCanvas {
            let newCenter = superview!.convert(center, to: controller.canvas)
            removeFromSuperview()
            controller.canvas.addSubview(self)
            center = newCenter
            onCanvas = true
        }
    }
    
}
