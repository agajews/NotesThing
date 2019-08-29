//
//  WebLink.swift
//  NotesThing
//
//  Created by Alex Gajewski on 8/28/19.
//  Copyright © 2019 Alex Gajewski. All rights reserved.
//

import UIKit

class WebLink: UIView {
    
    var url: URL
    let labelHeight: CGFloat = 20

    init(frame: CGRect, title: String, url: URL) {
        self.url = url
        super.init(frame: frame)
        
        let label = UILabel(frame: CGRect(x: frame.minX, y: frame.minY + frame.height - labelHeight, width: 200, height: labelHeight))
        label.center = self.center
        label.textAlignment = .center
        label.text = title
        self.addSubview(label)
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
