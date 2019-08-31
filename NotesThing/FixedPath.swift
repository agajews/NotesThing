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

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        // context.saveGState()
        context.setShadow(offset: CGSize(width: 0, height: 0), blur: 15.0)
        // let shadowX = 1 - shadowPixels / frame.width
        // let shadowY = 1 - shadowPixels / frame.height
        // let shrink = CGAffineTransform(a: shadowX, b: 0, c: 0, d: shadowY, tx: (1 - shadowX) / 2 * frame.width, ty: (1 - shadowY) / 2 * frame.height)
        // context.concatenate(shrink)
        context.addPath(path!)
        context.setFillColor(UIColor.black.cgColor)
        context.fillPath()
        context.clip(to: CGRect(x: 0, y: 0, width: frame.width, height: frame.height), mask: imageMask!)
        image!.draw(in: interior!)
        context.resetClip()
        context.addPath(displayPath!)
        context.setStrokeColor(UIColor.black.cgColor)
        context.strokePath()
    }
    
    func setPath(path: CGPath?, displayPath: CGPath?) {
        self.path = path
        self.displayPath = displayPath
        backgroundColor = UIColor.black.withAlphaComponent(0.0)
        
        UIGraphicsBeginImageContext(frame.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        context.fill(frame)
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: frame.height)
        context.concatenate(flipVertical)
        
        context.addPath(path!)
        context.setFillColor(UIColor.black.cgColor)
        context.fillPath()
        imageMask = context.makeImage()!
        UIGraphicsEndImageContext()
        
        setNeedsDisplay()
    }
    
}
