//
//  MPWebview.swift
//  MPWebview
//
//  Created by lintong on 2020/3/25.
//  Copyright © 2020 lintong. All rights reserved.
//

import UIKit
import WebKit
import SVGKit
import Lottie

let __SCREEN_WIDTH__  = UIScreen.main.bounds.size.width
let __SCREEN_HEIGHT__ = UIScreen.main.bounds.size.height

public enum MPWebviewStyle {
    case traditional //上面导航栏+下面tool
    case modern      //只有上面导航栏
    case concise     //只有右上方关闭按钮
    case fullScreen  //全屏模式
    case popup       //弹窗模式
}

public class MPWebview: UIView {
    @IBOutlet var contentView:UIView!
    @IBOutlet var topBar:UIView!
    @IBOutlet var bottomBar:UIView!
    @IBOutlet var webContent:UIView!
    @IBOutlet var topHeightConstraint:NSLayoutConstraint!
    @IBOutlet var bottomHeightConstraint:NSLayoutConstraint!
    
    var webview:WKWebView!
    
    //控件
    @IBOutlet var forwardBtn:UIButton!
    @IBOutlet var backwardBtn:UIButton!
    @IBOutlet var closeBtn:UIButton!
    @IBOutlet var refreshBtn:UIButton!
    @IBOutlet var titleLabel:UILabel!
    
    //Loading控件
    var activityActor:AnimationView!
    
    //title
    public var title:String = "" //native指定
    public var autoParseTitle:Bool = false //从网页获取title
    
    //白名单
    public var whiteList:Array<String> = []
    
    //特殊URL处理映射
    public var specialUrlMaps:Dictionary<String,(String)->Bool> = [:]
    
    //javascript注册事件
    public var jsMaps:Dictionary<String,(WKScriptMessage)->()> = [:]
    
    //统计事件Maps
    public var trackEventsMaps:Dictionary<String,String> = [:]
    
    //webview关闭回调
    public var webviewCloseBlock:()->() = {}
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Bundle.main.loadNibNamed("MPWebview", owner: self, options: nil)
        self.addSubview(contentView)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.frame = self.bounds;
        
        titleLabel.text = title
        
        forwardBtn.setImage(SVGKImage.init(named: "chevron-right.svg").uiImage, for: .normal)
        forwardBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        backwardBtn.setImage(SVGKImage.init(named: "chevron-left.svg").uiImage, for: .normal)
        backwardBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        closeBtn.setImage(SVGKImage.init(named: "x.svg").uiImage, for: .normal)
        closeBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        refreshBtn.setImage(SVGKImage.init(named: "rotate-right.svg").uiImage, for: .normal)
        refreshBtn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        closeBtn.tintColor = UIColor.black
        backwardBtn.tintColor = UIColor.black
        forwardBtn.tintColor = UIColor.black
        refreshBtn.tintColor = UIColor.black
        
        self.createAnimatorView()
        
        self.initWebview()
    }
    
    func initWebview(){
        let configuration = WKWebViewConfiguration();
        let userController = WKUserContentController();

        configuration.userContentController = userController;
        
        webview = WKWebView.init(frame: webContent.bounds, configuration: configuration)
        webview.navigationDelegate = self
        webContent.addSubview(webview)
    }
    
//    MARK:创建风火轮
    func createAnimatorView(){
        let animation = Animation.named("activityActor", bundle: Bundle.main, subdirectory: nil, animationCache: nil)
        activityActor = AnimationView(animation: animation)
        activityActor.contentMode = .scaleAspectFill
        activityActor.loopMode = .loop
        activityActor.bounds = CGRect(x: 0, y: 0, width: 150, height: 40)
        activityActor.center = CGPoint(x:__SCREEN_WIDTH__/2 , y: __SCREEN_HEIGHT__/2)
        
        self.addSubview(activityActor)
    }
    
//    MARK:风格设置
    public func setStyle(style:MPWebviewStyle){
        switch style {
        case .traditional:
            topBar.isHidden = false
            bottomBar.isHidden = false
            break
        case .modern:
            topBar.isHidden = false
            bottomBar.isHidden = true
            bottomHeightConstraint.constant = 0
            break
        case .concise:
            topBar.isHidden = false
            bottomBar.isHidden = true
            refreshBtn.isHidden = true
            bottomHeightConstraint.constant = 0
            break
        case .fullScreen:
            topBar.isHidden = true
            bottomBar.isHidden = true
            
            topHeightConstraint.constant = 0
            bottomHeightConstraint.constant = 0
            break
        case .popup:
            topBar.isHidden = true
            bottomBar.isHidden = true
            break
        }
    }
    
    public func setTintColor(color:UIColor){
        closeBtn.tintColor = color
        backwardBtn.tintColor = color
        forwardBtn.tintColor = color
        refreshBtn.tintColor = color
    }
    
    public func setTitleColor(color:UIColor){
        titleLabel.textColor = color
    }
    
    public func setToolBarColor(color:UIColor){
        topBar.backgroundColor = color
        bottomBar.backgroundColor = color
    }
//    MARK:添加Cookie
    public func setCookie(cookieProperties:Dictionary<HTTPCookiePropertyKey, Any>){
        let cookie = HTTPCookie.init(properties: cookieProperties)
        if(cookie != nil){
            HTTPCookieStorage.shared.setCookie(cookie!)
        }
    }
    
//    MARK:删除Cookie
    public func deleteCookie(urlStr:String){
        let url = URL(string: urlStr)
        guard url != nil else {
            return
        }
        let storage = HTTPCookieStorage.shared
        let cookies = storage.cookies(for: url!)
        if(cookies != nil){
            for ck in cookies!{
                storage.deleteCookie(ck)
            }
        }
    }
    
//    MARK:删除所有Cookie
    public func deleteAllCookies(){
        let cookies = HTTPCookieStorage.shared.cookies
        if(cookies != nil){
            for ck in cookies!{
                HTTPCookieStorage.shared.deleteCookie(ck)
            }
        }
    }
    
//    MARK:修改User-Agent
    public func configUserAgent(userAgent:String){
        webview.customUserAgent = userAgent
    }
    
//    MARK:控件事件
    @IBAction func clickGoback(sender:UIButton){
        if(webview.canGoBack){
            webview.goBack()
        }
    }
    
    @IBAction func clickForward(sender:UIButton){
        if(webview.canGoForward){
            webview.goForward()
        }
    }
    
    @IBAction func clickClose(sender:UIButton){
        
    }
    
    @IBAction func clickRefresh(sender:UIButton){
        webview.reload()
    }
    
//    MARK:事件追踪
    
    //添加追踪事件
   public func addTrackEventsMaps(maps:Dictionary<String,String>){
        for (key,value) in maps{
            trackEventsMaps[key] = value
        }
    }
    
    func sendTrackEvent(){
        
    }
//    MARK:加载URL
    public func loadUrl(urlStr:String){
        let url = URL(string: urlStr)
        guard url != nil else {
            return
        }
        let urlRequest = URLRequest(url: url!)
        self.webview.load(urlRequest)
    }
    
    
//    MARK:特殊URL处理
    
    //注册特殊URL回调
    //@callback 回调函数，返回的Bool值作为是否打开网页的标识(true,打开网页,反之不打开)
    public func registerSpecialUrlCallback(url:String,callback:@escaping (String)->Bool){
        specialUrlMaps[url] = callback
    }
    
    //取消特殊URL回调
    public func unregisterSpecialUrlCallback(url:String){
        specialUrlMaps.removeValue(forKey: url)
    }
    
//    MARK:JavaScript交互
    public func excuteJavascript(javascript:String,completion:@escaping (Any?,Error?)->()){
        webview.evaluateJavaScript(javascript) { (result, error) in
            if(error == nil){
                completion(result,error)
            }else{
                NSLog("Excute Javascript Error:%@", error?.localizedDescription ?? "")
            }
        }
    }
    
    //注册javascript回调事件
    public func registerJavascriptCallback(name:String,callback:@escaping (WKScriptMessage)->()){
        jsMaps[name] = callback
        webview.configuration.userContentController.add(self, name: name)
    }
    
    //取消已注册事件
    public func unregisterJavascriptCallback(name:String){
        jsMaps.removeValue(forKey: name)
        webview.configuration.userContentController.removeScriptMessageHandler(forName: name)
    }
}

//MARK:WKWebview回调
extension MPWebview:WKNavigationDelegate{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
        let urlStr = navigationAction.request.url?.absoluteString
        
        //处理统计事件
        let trackValue = trackEventsMaps[urlStr ?? ""]
        if(trackValue != nil){
            //发送统计事件
        }
        
        //处理特殊URL追踪
        let specialUrlCallback = specialUrlMaps[urlStr ?? ""]
        if(specialUrlCallback != nil){
            let allowOpen = specialUrlCallback!(urlStr!)
            if(allowOpen){
                decisionHandler(.allow)
            }else{
                decisionHandler(.cancel)
            }
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        activityActor.play()
        activityActor.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
        activityActor.stop()
        activityActor.isHidden = true
        if(autoParseTitle){
            webView.evaluateJavaScript("document.title") { (object, error) in
                self.titleLabel.text = object as? String
            }
        }
    }
}

extension MPWebview:WKUIDelegate{
    func webViewDidClose(_ webView: WKWebView){
        webviewCloseBlock()
    }
}

//MARK:JavaScript回调
extension MPWebview:WKScriptMessageHandler{
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        let messageName = message.name
        let callback = jsMaps[messageName]
        
        //执行回调
        if(callback != nil){
            callback!(message)
        }else{
            NSLog("事件未注册==>%@",messageName)
        }
    }
}
