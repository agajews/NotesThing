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
    @IBOutlet weak var circler: CirclerView!
    @IBOutlet var circlerRecognizer: CirclerRecognizer!
    @IBOutlet weak var outerCircler: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navbar: UINavigationBar!
    var canvasExpanded = false
    var urlTapRecognizer: UITapGestureRecognizer? = nil
    var nextWebOffset: CGPoint? = nil
    let navbarHeight = 50
    let splitPoint = 1150
    let totalWidth = 1366
    let expandDuration = 0.15

    override func viewDidLoad() {
        super.viewDidLoad()

        urlField.delegate = self
        webView.navigationDelegate = self
        
        let barColor = UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 1.0)
        toolbar.backgroundColor = barColor
        navbar.backgroundColor = barColor
        urlField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        urlField.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        urlField.font = UIFont(name: "Damascus", size: 16)
        urlField.adjustsFontSizeToFitWidth = true
        urlField.textAlignment = .center
        urlField.contentVerticalAlignment = .bottom
        urlField.layer.cornerRadius = 10
        urlField.layer.masksToBounds = true
        urlField.layer.borderColor = barColor.cgColor
        urlField.layer.borderWidth = 1
        urlField.borderStyle = .roundedRect
        // urlField.placeholder = "Search..."
        
        urlTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.urlTapped(gestureRecognizer:)))
        urlField.addGestureRecognizer(urlTapRecognizer!)

        outerCircler.frame = CGRect(x: 0, y: navbarHeight, width: splitPoint, height: 930)
        webView.frame = CGRect(x: 0, y: 0, width: splitPoint, height: 930)
        circler.frame = webView.frame
        webBox.frame = outerCircler.frame
        canvas.frame = CGRect(x: 0, y: 0, width: 3000, height: 3000)
        expandScrollView()

        webBox.tapTrigger = self.webTapped
        webBox.backgroundColor = UIColor.black.withAlphaComponent(0)
        webBox.name = "web"
        
        circler.isUserInteractionEnabled = false
        circler.backgroundColor = UIColor.black.withAlphaComponent(0)
        circler.webView = webView
        circlerRecognizer.allowedTouchTypes = [UITouch.TouchType.pencil.rawValue as NSNumber]
        circlerRecognizer.circler = circler

        canvasScroll.minimumZoomScale = max(canvasScroll.visibleSize.width / canvas.frame.width, canvasScroll.visibleSize.height / canvas.frame.height)
        canvasScroll.contentSize = canvas.bounds.size
        canvasScroll.panGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        canvasScroll.delegate = self

        scrollBox.layer.shadowColor = UIColor.gray.cgColor
        scrollBox.layer.shadowOpacity = 1
        scrollBox.layer.shadowOffset = .zero
        scrollBox.layer.shadowRadius = 5
        scrollBox.layer.masksToBounds = false
        
        scrollTapBox.isUserInteractionEnabled = true
        scrollTapBox.tapTrigger = self.scrollTapped
        scrollTapBox.backgroundColor = UIColor.black.withAlphaComponent(0)
        scrollTapBox.name = "scroll"

        expandWebView()

        print(scrollTapBox.frame)
        print(webBox.frame)

        webView.allowsBackForwardNavigationGestures = true
        let myURL = URL(string:"https://www.google.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        
        if textField.text != nil {
            let query = textField.text!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let myURL = URL(string: "https://www.google.com/search?q=" + query)
            let myRequest = URLRequest(url: myURL!)
            webView.load(myRequest)
            animateExpandWebView()
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        urlTapRecognizer?.isEnabled = true
        return true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        /* if navigationAction.navigationType == .linkActivated  {
            let url = navigationAction.request.url
            urlField.text = url?.absoluteString
        } */
        decisionHandler(.allow)
    }
    
    func loadUrl(_ url: URL?, offset: CGPoint) {
        let request = URLRequest(url: url!)
        webView.load(request)
        nextWebOffset = offset
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !webView.url!.absoluteString.starts(with: "https://www.google.com") {
            urlField.text = webView.title
        }
        if nextWebOffset != nil {
            webView.scrollView.contentOffset = nextWebOffset!
            nextWebOffset = nil
        }
    }

    @IBAction func urlPan(_ sender: UIPanGestureRecognizer) {
        /* if sender.state == .ended {
            let webLink = WebLink(frame: CGRect(x: 0, y: 0, width: 200, height: 20), title: webView.title!, url: webView.url!)
            webLink.center = sender.location(in: canvas)
            canvas.addSubview(webLink)
            
            /*let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            label.center = sender.location(in: canvas)
            label.textAlignment = .center
            label.text = webView.title!
            canvas.addSubview(label)*/
        } */
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvas
    }
    
    func expandWebView() {
        self.canvasScroll.frame = CGRect(x: self.splitPoint, y: navbarHeight, width: self.totalWidth - self.splitPoint, height: 930)
        self.scrollBox.frame = self.canvasScroll.frame
        self.scrollTapBox.frame = self.canvasScroll.frame
    }
    
    func expandScrollView() {
        self.canvasScroll.frame = CGRect(x: self.totalWidth - self.splitPoint, y: navbarHeight, width: self.splitPoint, height: 930)
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
    
    @IBAction func webBack(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func webForward(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @objc func urlTapped(gestureRecognizer: UITapGestureRecognizer) {
        urlField.becomeFirstResponder()
        urlField.selectAll(nil)
        gestureRecognizer.isEnabled = false
    }
}

