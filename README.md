# MPWebview
A WKWebview (using Swift 4.0) that allows users to set cookies,set user-agent,jascript interaction,UI Style and so on.
# Installation
pod 'MPWebview'

# Style
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
# Add cookie
```swift
func setCookie(cookieProperties:Dictionary<HTTPCookiePropertyKey, Any>)
```
# Delete cookie
delete cookies of special url.
```swift
func deleteCookie(urlStr:String)
```

# Delete all cookies
```swift
func deleteAllCookies()
```
# User-Agent
```swift
webview.configUserAgent(userAgent: "ios 1.2.1 safari")
```
# Javascript interaction
javascript call native
```swift
webview.registerJavascriptCallback(name: "firebaseMessage") { (msg) in
            NSLog("receive %@", msg)
        }
```
native call javascript
```swift
func excuteJavascript(javascript:String,completion:@escaping (Any?,Error?)->())
```

# Author
tian@marcopolos.co.jp, lintong@withease.cn

# License
MPWebview is available under the MIT license. See the LICENSE file for more info.
