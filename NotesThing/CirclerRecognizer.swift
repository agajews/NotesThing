//
//  CirclerRecognizer.swift
//  NotesThing
//
//  Created by Alex Gajewski on 8/29/19.
//  Copyright © 2019 Alex Gajewski. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class CirclerRecognizer: UIGestureRecognizer {
    var circler: UIView? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .began
        circler!.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .changed
        circler!.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .ended
        circler!.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .cancelled
        circler!.touchesCancelled(touches, with: event)
    }
}
