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
    var initPress: CGPoint? = nil
    var url: URL? = nil
    var webOffset: CGPoint? = nil
    var onCanvas = false
    var moving = false
    var onTrash = false

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        // context.saveGState()
        if moving {
            context.setShadow(offset: CGSize(width: 0, height: 3), blur: 15.0, color: UIColor.gray.cgColor)
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
    
    func clip(_ num: CGFloat, lo: CGFloat, hi: CGFloat) -> CGFloat {
        if num < lo {
            return lo
        }
        if num > hi {
            return hi
        }
        return num
    }
    
    @objc func handlePress(gestureRecognizer: UILongPressGestureRecognizer) {
        let controller = (window!.rootViewController as! ViewController)
        
        if gestureRecognizer.state == .began {
            initCenter = center
            initPress = gestureRecognizer.location(in: superview!)
            controller.animateExpandScrollView()

            if onCanvas {
                controller.trashBox!.image = controller.blackTrash
                UIView.animate(withDuration: controller.trashDuration, animations: {
                    controller.trashBox!.frame = controller.trashBoxFrame!
                })
            }
            
            moving = true
            setNeedsDisplay()
            return
        }
        
        let location = gestureRecognizer.location(in: superview!)
        if onCanvas {
            center = CGPoint(x: clip(initCenter!.x + location.x - initPress!.x, lo: 0, hi: controller.canvas.frame.width), y: clip(initCenter!.y + location.y - initPress!.y, lo: 0, hi: controller.canvas.frame.height))
        } else {
            center = CGPoint(x: initCenter!.x + location.x - initPress!.x, y: initCenter!.y + location.y - initPress!.y)
        }

        if gestureRecognizer.state == .ended {
            moving = false
            onTrash = false
            // controller.trashBox!.removeFromSuperview()
            UIView.animate(withDuration: controller.trashDuration, animations: {
                controller.trashBox!.frame = controller.trashBoxOffscreenFrame!
            })
            setNeedsDisplay()
        }
        
        let viewLocation = gestureRecognizer.location(in: controller.view!)
        let testCenter = superview!.convert(location, to: controller.canvasScroll)
        
        if onCanvas {
            if controller.trashBoxFrame!.contains(viewLocation) {
                if !onTrash {
                    UIView.transition(with: controller.trashBox!,
                                      duration: 0.15,
                                      options: .transitionCrossDissolve,
                                      animations: {
                                        controller.trashBox!.image = controller.redTrash!
                    }, completion: nil)
                    onTrash = true
                }
                if gestureRecognizer.state == .ended {
                    self.removeFromSuperview()
                    return
                }
            } else {
                if onTrash {
                    UIView.transition(with: controller.trashBox!,
                                      duration: 0.15,
                                      options: .transitionCrossDissolve,
                                      animations: {
                                        controller.trashBox!.image = controller.blackTrash!
                    }, completion: nil)
                    onTrash = false
                }
            }
        } else {
            if gestureRecognizer.state == .ended && controller.canvasScroll.point(inside: testCenter, with: nil) {
                let newCenter = superview!.convert(center, to: controller.outerCanvas)
                removeFromSuperview()
                controller.outerCanvas.insertSubview(self, belowSubview: controller.canvas)
                center = newCenter
                onCanvas = true
                gestureRecognizer.minimumPressDuration = 0.1
            }
        }

    }
    
    @objc func handleTap(gestureRecognizer: UIPanGestureRecognizer) {
        let controller = (window!.rootViewController as! ViewController)
        controller.loadUrl(url, offset: webOffset!)
        controller.animateExpandWebView()
    }

}
