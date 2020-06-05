# MPWebview
A WKWebview (using Swift 4.0) that allows users to set cookies,set user-agent,jascript interaction,UI Style and so on.
# Installation
pod 'MPWebview'

# 风格设置
```swift
traditional //上面导航栏+下面tool
modern      //只有上面导航栏
concise     //只有右上方关闭按钮
fullScreen  //全屏模式
popup       //弹窗模式
```

```swift
webview.setStyle(style: .traditional)
```
# 添加Cookie
```swift
func setCookie(cookieProperties:Dictionary<HTTPCookiePropertyKey, Any>)
```
# 删除Cookie
删除指定url下面的所有cookie
```swift
func deleteCookie(urlStr:String)
```

# 清除所有cookie
```swift
func deleteAllCookies()
```
# 自定义user-agent
```swift
webview.configUserAgent(userAgent: "ios 1.2.1 safari")
```
# 与javascript交互
javascript调用native
```swift
webview.registerJavascriptCallback(name: "firebaseMessage") { (msg) in
            NSLog("receive %@", msg)
        }
```
native调用javascript
```swift
func excuteJavascript(javascript:String,completion:@escaping (Any?,Error?)->())
```
# 特殊Url追踪处理
检测到指定的Url后的回调函数处理，return true表示处理后继续打开页面，反之。
```swift
webview.registerSpecialUrlCallback(url: "otb://") { (url) -> Bool in
            //do something
            return true
            }
```

# 事件追踪
```swift
webview.addTrackEventsMaps(maps: ["https://baidu":"baiduEvent","google.com":"googleEvent"])
```

# Author
tian@marcopolos.co.jp, lintong@withease.cn

# License
MPWebview is available under the MIT license. See the LICENSE file for more info.
