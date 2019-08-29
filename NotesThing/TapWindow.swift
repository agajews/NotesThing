//
//  TapWindow.swift
//  NotesThing
//
//  Created by Alex Gajewski on 8/28/19.
//  Copyright © 2019 Alex Gajewski. All rights reserved.
//

import UIKit
import WebKit

class TapWindow: UIWindow {
    
    /* func webViewPencil(_ event: UIEvent) -> UITouch? {
        let touches = event.touches(for: self.subviews[0].subviews[0].subviews[0].subviews[0].subviews[0].subviews[0])
        if touches == nil {
            return nil
        }
        if touches!.first == nil {
            return nil
        }
        let touch = touches!.first!
        if touch.type == .pencil {
            return touch
        }
        return nil
    }

    override func sendEvent(_ event: UIEvent) {
        let pencilTouch = webViewPencil(event)
        if pencilTouch != nil {
            let touches = Set([pencilTouch!])
            if pencilTouch!.phase == .began {
                self.subviews[0].subviews[1].touchesBegan(touches, with: event)
            } else if pencilTouch!.phase == .moved {
                self.subviews[0].subviews[1].touchesMoved(touches, with: event)
            } else if pencilTouch!.phase == .ended {
                self.subviews[0].subviews[1].touchesEnded(touches, with: event)
            } else if pencilTouch!.phase == .cancelled {
                self.subviews[0].subviews[1].touchesCancelled(touches, with: event)
            }
        } else {
            super.sendEvent(event)
        }
    } */

}
