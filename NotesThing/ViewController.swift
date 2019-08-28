//
//  ViewController.swift
//  NotesThing
//
//  Created by Alex Gajewski on 8/25/19.
//  Copyright © 2019 Alex Gajewski. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate, UIScrollViewDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var canvas: CanvasView!
    @IBOutlet weak var canvasScroll: UIScrollView!
    @IBOutlet weak var scrollBox: UIView!
    @IBOutlet weak var webBox: TapBox!
    @IBOutlet weak var scrollTapBox: TapBox!
    var canvasExpanded = false
    let splitPoint = 1050
    let totalWidth = 1366
    let expandDuration = 0.15

    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlField.delegate = self
        webView.navigationDelegate = self
        
        webBox.tapTrigger = self.webTapped
        webBox.frame = webView.frame
        webBox.backgroundColor = UIColor.black.withAlphaComponent(0)

        canvas.frame = CGRect(x: 0, y: 0, width: 3000, height: 3000)
        
        expandScrollView()

        canvasScroll.minimumZoomScale = max(canvasScroll.visibleSize.width / canvas.frame.width, canvasScroll.visibleSize.height / canvas.frame.height)
        canvasScroll.contentSize = canvas.bounds.size
        canvasScroll.panGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        canvasScroll.delegate = self
        webView.frame = CGRect(x: 0, y: 50, width: splitPoint, height: 930)
        
        expandWebView()

        scrollBox.layer.shadowColor = UIColor.gray.cgColor
        scrollBox.layer.shadowOpacity = 1
        scrollBox.layer.shadowOffset = .zero
        scrollBox.layer.shadowRadius = 5
        scrollBox.layer.masksToBounds = false
        
        scrollTapBox.tapTrigger = self.scrollTapped
        scrollTapBox.backgroundColor = UIColor.black.withAlphaComponent(0)
        
        let myURL = URL(string:"https://www.google.com")
        let myRequest = URLRequest(url: myURL!)
        urlField.text = myURL?.absoluteString
        webView.load(myRequest)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        
        if textField.text != nil {
            let myURL = URL(string:textField.text!)
            let myRequest = URLRequest(url: myURL!)
            webView.load(myRequest)
        }
        
        return true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            let url = navigationAction.request.url
            urlField.text = url?.absoluteString
        }
        decisionHandler(.allow)
    }

    @IBAction func urlPan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            label.center = sender.location(in: canvas)
            label.textAlignment = .center
            label.text = webView.title!
            canvas.addSubview(label)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvas
    }
    
    func expandWebView() {
        self.canvasScroll.frame = CGRect(x: self.splitPoint, y: 50, width: self.totalWidth - self.splitPoint, height: 930)
        self.scrollBox.frame = self.canvasScroll.frame
        self.scrollTapBox.frame = self.canvasScroll.frame
    }
    
    func expandScrollView() {
        self.canvasScroll.frame = CGRect(x: self.totalWidth - self.splitPoint, y: 50, width: self.splitPoint, height: 930)
        self.scrollBox.frame = self.canvasScroll.frame
        self.scrollTapBox.frame = self.canvasScroll.frame
    }
    
    func animateExpandWebView() {
        UIView.animate(withDuration: expandDuration, animations: {
            self.expandWebView()
        })
        canvasExpanded = false
    }
    
    func animateExpandScrollView() {
        UIView.animate(withDuration: expandDuration, animations: {
            self.expandScrollView()
        })
        canvasExpanded = true
    }
    
    func webTapped() {
        if canvasExpanded {
            animateExpandWebView()
        }
    }
    
    func scrollTapped() {
        if !canvasExpanded {
            animateExpandScrollView()
        }
    }

}

