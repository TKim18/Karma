//
//  MenuViewController.swift
//  Karma
//
//  Created by Timothy Taeho Kim on 4/28/18.
//  Copyright © 2018 Olya Danylova. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UIWebViewDelegate {

    var category : Order.Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myWebView : UIWebView = UIWebView(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: self.view.frame.height))
        
        myWebView.delegate = self
        self.view.addSubview(myWebView)
        
        let request = URLRequest(url: category.menuURL);
        myWebView.loadRequest(request);
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("Web view start loading")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("Web view load completely")
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Web view loading fail : ",error.localizedDescription)
    }
}
