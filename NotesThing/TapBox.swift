//
//  TapBox.swift
//  NotesThing
//
//  Created by Alex Gajewski on 8/27/19.
//  Copyright © 2019 Alex Gajewski. All rights reserved.
//

import UIKit

class TapBox: UIView {
    
    var tapTrigger: (()->Void)? = nil
    var name: String? = nil

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if tapTrigger != nil && view == self {
            tapTrigger!()
        }
        return view == self ? nil : view
    }

}
