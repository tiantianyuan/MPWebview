//
//  ViewController.swift
//  MPWebview
//
//  Created by tian@marcopolos.co.jp on 06/04/2020.
//  Copyright (c) 2020 tian@marcopolos.co.jp. All rights reserved.
//

import UIKit
import MPWebview

class ViewController: UIViewController {
    @IBOutlet var webview:MPWebview!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.addSubview(contentView)
        // Do any additional setup after loading the view, typically from a nib.
        webview.setStyle(style: .popup)
        webview.setTintColor(color: UIColor.blue)
        webview.registerJavascriptCallback(name: "firebaseMessage") { (msg) in
        }
                
        webview.addTrackEventsMaps(maps: ["https://baidu":"baidu","google.com":"google"])
        webview.registerSpecialUrlCallback(url: "otb://") { (url) -> Bool in
                    return true
        }
        //        webview.configUserAgent(userAgent: "ios 1.2.1 safari")
        webview.loadUrl(urlStr: "https://www.baidu.com")
        webview.autoParseTitle = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

