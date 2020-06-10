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
import Masonry

let __SCREEN_WIDTH__  = UIScreen.main.bounds.size.width
let __SCREEN_HEIGHT__ = UIScreen.main.bounds.size.height
func isiPhoneXScreen() -> Bool {
        guard #available(iOS 11.0, *) else {
            return false
        }
    return UIApplication.shared.windows[0].safeAreaInsets.bottom != 0
}

public enum MPWebviewStyle {
    case traditional //上面导航栏+下面tool
    case modern      //只有上面导航栏
    case concise     //只有右上方关闭按钮
    case fullScreen  //全屏模式
    case popup       //弹窗模式
}

public class MPWebview: UIView {
    var contentView:UIView!
    var topBar:UIView!
    var bottomBar:UIView!
    var webContent:UIView!
    var topHeightConstraint:NSLayoutConstraint!
    var bottomHeightConstraint:NSLayoutConstraint!
    
    var webview:WKWebView!
    
    //控件
    var forwardBtn:UIButton!
    var backwardBtn:UIButton!
    var closeBtn:UIButton!
    var refreshBtn:UIButton!
    var titleLabel:UILabel!
    
    //Loading控件
    public var activityActor:AnimationView!
    
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        NSLog("init frame")
        self.config()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initView(frame:CGRect){
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.addSubview(contentView)
        contentView.mas_makeConstraints { (make) in
            make?.top.equalTo()(0)
            make?.bottom.equalTo()(0)
            make?.leading.equalTo()(0)
            make?.trailing.equalTo()(0)
        }
        
        topBar = UIView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 86))
        contentView.addSubview(topBar)
        topBar.mas_makeConstraints { (make) in
            make?.top.mas_equalTo()(0)
            make?.leading.mas_equalTo()(0)
            make?.trailing.mas_equalTo()(0)
            if(isiPhoneXScreen()){
                make?.height.mas_equalTo()(86)
            }else{
                make?.height.mas_equalTo()(64)
            }
        }
        
        bottomBar = UIView(frame: CGRect(x: 0, y: 0, width: contentView.frame.width, height: 44))
        contentView.addSubview(bottomBar)
        bottomBar.mas_makeConstraints { (make) in
            make?.bottom.equalTo()(superview?.mas_bottom)
            if(isiPhoneXScreen()){
                make?.height.mas_equalTo()(78)
            }else{
                make?.height.mas_equalTo()(44)
            }
            
            make?.leading.mas_equalTo()(0)
            make?.trailing.mas_equalTo()(0)
        }
        
        webContent = UIView(frame: CGRect(x: 0, y: topBar.frame.maxY, width: contentView.frame.width, height: 0))
        contentView.addSubview(webContent)
        webContent.mas_makeConstraints { (make) in
            make?.top.equalTo()(topBar.mas_bottom)
            make?.leading.mas_equalTo()(0)
            make?.trailing.mas_equalTo()(0)
            make?.bottom.equalTo()(bottomBar.mas_top)
            
        }
        
        forwardBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        bottomBar.addSubview(forwardBtn)
        forwardBtn.mas_makeConstraints { (make) in
            make?.leading.mas_equalTo()(100)
            make?.top.mas_equalTo()(5)
            make?.width.mas_equalTo()(40)
            make?.height.mas_equalTo()(40)
        }
        
        backwardBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        bottomBar.addSubview(backwardBtn)
        backwardBtn.mas_makeConstraints { (make) in
            make?.leading.mas_equalTo()(20)
            make?.top.mas_equalTo()(5)
            make?.width.mas_equalTo()(40)
            make?.height.mas_equalTo()(40)
        }
        
        closeBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        topBar.addSubview(closeBtn)
        closeBtn.mas_makeConstraints { (make) in
            make?.leading.mas_equalTo()(10)
            make?.bottom.mas_equalTo()(-5)
            make?.width.mas_equalTo()(40)
            make?.height.mas_equalTo()(40)
        }
        
        refreshBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        topBar.addSubview(refreshBtn)
        refreshBtn.mas_makeConstraints { (make) in
            make?.trailing.mas_equalTo()(-10)
            make?.bottom.mas_equalTo()(-5)
            make?.width.mas_equalTo()(40)
            make?.height.mas_equalTo()(40)
        }
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        topBar.addSubview(titleLabel)
        titleLabel.mas_makeConstraints { (make) in
            make?.centerX.equalTo()(superview?.mas_centerX)
            make?.bottom.mas_equalTo()(-15)
            make?.leading.mas_greaterThanOrEqualTo()(60)
            make?.trailing.mas_lessThanOrEqualTo()(-60)
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        NSLog("awake from nib")
        self.config()
    }
    
    func currentBundle()->Bundle{
        let bundle = Bundle.init(for: type(of: self))
        let path = bundle.path(forResource: "MPWebview", ofType: "bundle")
        let resource = path != nil ? Bundle.init(path: path!) : Bundle.main
        return resource!
    }
    
    func config(){
        self.initView(frame: self.frame)
        self.contentView.frame = self.bounds;
        
        titleLabel.text = title
        
        forwardBtn.setImage(SVGKImage.init(named: "chevron-right.svg", in: self.currentBundle()).uiImage, for: .normal)
        forwardBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        forwardBtn.addTarget(self, action: #selector(clickForward(sender:)), for: .touchUpInside)
        
        backwardBtn.setImage(SVGKImage.init(named: "chevron-left.svg", in: self.currentBundle()).uiImage, for: .normal)
        backwardBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        backwardBtn.addTarget(self, action: #selector(clickGoback(sender:)), for: .touchUpInside)
        
        closeBtn.setImage(SVGKImage.init(named: "x.svg", in: self.currentBundle()).uiImage, for: .normal)
        closeBtn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        closeBtn.addTarget(self, action: #selector(clickClose(sender:)), for: .touchUpInside)
        
        refreshBtn.setImage(SVGKImage.init(named: "rotate-right.svg", in: self.currentBundle()).uiImage, for: .normal)
        refreshBtn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        refreshBtn.addTarget(self, action: #selector(clickRefresh(sender:)), for: .touchUpInside)
        
        closeBtn.tintColor = UIColor.black
        backwardBtn.tintColor = UIColor.black
        forwardBtn.tintColor = UIColor.black
        refreshBtn.tintColor = UIColor.black
        
        self.createAnimatorView()
        
        self.initWebview()
        
        self.updateConstraints()
    }
    
    func initWebview(){
        let configuration = WKWebViewConfiguration();
        let userController = WKUserContentController();

        configuration.userContentController = userController;
        
        webview = WKWebView.init(frame: webContent.bounds, configuration: configuration)
        webview.navigationDelegate = self
        webContent.addSubview(webview)
        
        webview.mas_makeConstraints { (make) in
            make?.top.equalTo()(0)
            make?.bottom.equalTo()(0)
            make?.leading.equalTo()(0)
            make?.trailing.equalTo()(0)
        }
    }
    
//    MARK:创建风火轮
    func createAnimatorView(){
        let animation = Animation.named("activityActor", bundle: self.currentBundle(), subdirectory: nil, animationCache: nil)
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
            bottomBar.mas_remakeConstraints { (make) in
                make?.bottom.equalTo()(superview?.mas_bottom)
                make?.height.mas_equalTo()(0)
                make?.leading.mas_equalTo()(0)
                make?.trailing.mas_equalTo()(0)
            }
            self.updateConstraints()
            break
        case .concise:
            topBar.isHidden = false
            bottomBar.isHidden = true
            refreshBtn.isHidden = true
            bottomBar.mas_remakeConstraints { (make) in
                make?.bottom.equalTo()(superview?.mas_bottom)
                make?.height.mas_equalTo()(0)
                make?.leading.mas_equalTo()(0)
                make?.trailing.mas_equalTo()(0)
            }
            self.updateConstraints()
            break
        case .fullScreen:
            topBar.isHidden = true
            bottomBar.isHidden = true
            
            topBar.mas_remakeConstraints { (make) in
                make?.top.mas_equalTo()(0)
                make?.leading.mas_equalTo()(0)
                make?.trailing.mas_equalTo()(0)
                make?.height.mas_equalTo()(0)
            }

            bottomBar.mas_remakeConstraints { (make) in
                make?.bottom.equalTo()(superview?.mas_bottom)
                make?.height.mas_equalTo()(0)
                make?.leading.mas_equalTo()(0)
                make?.trailing.mas_equalTo()(0)
            }
            self.updateConstraints()
            break
        case .popup:
            topBar.isHidden = false
            bottomBar.isHidden = true
            refreshBtn.isHidden = true
            bottomBar.mas_remakeConstraints { (make) in
                make?.bottom.equalTo()(superview?.mas_bottom)
                make?.height.mas_equalTo()(0)
                make?.leading.mas_equalTo()(0)
                make?.trailing.mas_equalTo()(0)
            }
            
            closeBtn.mas_remakeConstraints { (make) in
                make?.trailing.mas_equalTo()(-10)
                make?.bottom.mas_equalTo()(-5)
                make?.width.mas_equalTo()(40)
                make?.height.mas_equalTo()(40)
            }
            self.updateConstraints()
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
    @objc func clickGoback(sender:UIButton){
        if(webview.canGoBack){
            webview.goBack()
        }
    }
    
    @objc func clickForward(sender:UIButton){
        if(webview.canGoForward){
            webview.goForward()
        }
    }
    
    @objc func clickClose(sender:UIButton){
        
    }
    
    @objc func clickRefresh(sender:UIButton){
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
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void){
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
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!){
        activityActor.play()
        activityActor.isHidden = false
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!){
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
    public func webViewDidClose(_ webView: WKWebView){
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
