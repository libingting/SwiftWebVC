//
//  SwiftWebVC.swift
//
//  Created by Myles Ringle on 24/06/2015.
//  Transcribed from code used in SVWebViewController.
//  Copyright (c) 2015 Myles Ringle & Sam Vermette. All rights reserved.
//

import WebKit
import MonkeyKing
import MBUIKit
import MBCoreKit

public protocol SwiftWebVCDelegate: class {
  func didStartLoading()
  func didFinishLoading(success: Bool)
}

public class SwiftWebVC: UIViewController {
  
  public weak var delegate: SwiftWebVCDelegate?
  var storedStatusColor: UIBarStyle?
  var buttonColor: UIColor? = nil
  var titleColor: UIColor? = nil
  var closing: Bool! = false
  /// 启用简洁后就不显示下面的bar
  var customRightItem: UIBarButtonItem?
  
  lazy var backBarButtonItem: UIBarButtonItem =  {
    var tempBackBarButtonItem = UIBarButtonItem(image: SwiftWebVC.bundledImage(named: "SwiftWebVCBack"),
                                                style: UIBarButtonItemStyle.plain,
                                                target: self,
                                                action: #selector(SwiftWebVC.goBackTapped(_:)))
    tempBackBarButtonItem.width = 18.0
    tempBackBarButtonItem.tintColor = self.buttonColor
    return tempBackBarButtonItem
  }()
  
  lazy var forwardBarButtonItem: UIBarButtonItem =  {
    var tempForwardBarButtonItem = UIBarButtonItem(image: SwiftWebVC.bundledImage(named: "SwiftWebVCNext"),
                                                   style: UIBarButtonItemStyle.plain,
                                                   target: self,
                                                   action: #selector(SwiftWebVC.goForwardTapped(_:)))
    tempForwardBarButtonItem.width = 18.0
    tempForwardBarButtonItem.tintColor = self.buttonColor
    return tempForwardBarButtonItem
  }()
  
  lazy var refreshBarButtonItem: UIBarButtonItem = {
    var tempRefreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh,
                                                   target: self,
                                                   action: #selector(SwiftWebVC.reloadTapped(_:)))
    tempRefreshBarButtonItem.tintColor = self.buttonColor
    return tempRefreshBarButtonItem
  }()
  
  lazy var stopBarButtonItem: UIBarButtonItem = {
    var tempStopBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop,
                                                target: self,
                                                action: #selector(SwiftWebVC.stopTapped(_:)))
    tempStopBarButtonItem.tintColor = self.buttonColor
    return tempStopBarButtonItem
  }()
  
  lazy var actionBarButtonItem: UIBarButtonItem = {
    var tempActionBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action,
                                                  target: self,
                                                  action: #selector(SwiftWebVC.actionButtonTapped(_:)))
    tempActionBarButtonItem.tintColor = self.buttonColor
    return tempActionBarButtonItem
  }()
  
  
  public lazy var webView: WKWebView = {
    var tempWebView = WKWebView(frame: UIScreen.main.bounds)
    hasLoadWebView = true
    return tempWebView;
  }()
  
  public var request: URLRequest!
  
  public var navBarTitle: UILabel!
  
  var sharingEnabled = true
  
  /// 分享源 如果默认情况下为当前页面
  var sharingUrl: String?
  
  //// 分享的图标
  var sharingUrlIcon: UIImage?
  
  /// 网页标题， 默认的情况下为网页自动标题
  var webTitle: String?
  
  /// 已经载入了url
  var hasLoadWebView: Bool = false
  
  ////////////////////////////////////////////////
  
  deinit {
    logging("浏览器webview被释放")
    if hasLoadWebView {
      webView.scrollView.delegate = nil
      webView.stopLoading()
      webView.uiDelegate = nil;
      webView.navigationDelegate = nil;
    }
    UIApplication.shared.isNetworkActivityIndicatorVisible = false

  }
  
  public convenience init(urlString: String,
                          sharingEnabled: Bool = true,
                          sharingUrl: String? = nil,
                          sharingUrlIcon: UIImage? = nil,
                          title: String? = nil,
                          customRightItem: UIBarButtonItem? = nil) {
    var urlString = urlString
    if !urlString.hasPrefix("https://") && !urlString.hasPrefix("http://") {
      urlString = "https://"+urlString
    }
    self.init(pageURL: URL(string: urlString)!, sharingEnabled: sharingEnabled, sharingUrl: sharingUrl, sharingUrlIcon: sharingUrlIcon, title: title, customRightItem: customRightItem)
  }
  
  public convenience init(pageURL: URL,
                          sharingEnabled: Bool = true,
                          sharingUrl: String? = nil,
                          sharingUrlIcon: UIImage? = nil,
                          title: String? = nil,
                          customRightItem: UIBarButtonItem? = nil) {
    self.init(aRequest: URLRequest(url: pageURL), sharingEnabled: sharingEnabled, sharingUrl: sharingUrl, sharingUrlIcon: sharingUrlIcon, title: title, customRightItem: customRightItem)
  }
  
  /// 初始化网页
  ///
  /// - Parameters:
  ///   - aRequest: 当前请求
  ///   - sharingEnabled: 是否开启分享
  ///   - sharingUrl: 自定义的分享，要是不传就是当前网页的网址
  ///   - title: 当前网页的标题
  public convenience init(aRequest: URLRequest, sharingEnabled: Bool = true, sharingUrl: String? = nil, sharingUrlIcon: UIImage? = nil, title: String? = nil,
                          customRightItem: UIBarButtonItem? = nil) {
    self.init()
    self.webView.uiDelegate = self
    self.webView.navigationDelegate = self
    self.webTitle = title;
    self.sharingUrl = sharingUrl
    self.sharingUrlIcon = sharingUrlIcon
    self.sharingEnabled = sharingEnabled
    self.request = aRequest
    if let customRightItemTmp = customRightItem {
      self.customRightItem = customRightItemTmp
    }
  }
  
  func loadRequest(_ request: URLRequest) {
    webView.load(request)
  }
  
  ////////////////////////////////////////////////
  // View Lifecycle
  
  override public func loadView() {
    view = webView
    loadRequest(request)
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    self.hidesBottomBarWhenPushed = true
  }
  
  override public func viewWillAppear(_ animated: Bool) {
    assert(self.navigationController != nil, "SVWebViewController needs to be contained in a UINavigationController. If you are presenting SVWebViewController modally, use SVModalWebViewController instead.")
    updateToolbarItems()
    
    navBarTitle = UILabel()
    if let titleTmp = self.webTitle {
      navBarTitle.text = titleTmp
    }
    navBarTitle.backgroundColor = UIColor.clear
    if presentingViewController == nil {
      if let titleAttributes = navigationController!.navigationBar.titleTextAttributes {
        navBarTitle.textColor = titleAttributes[.foregroundColor] as? UIColor
      }
    }
    else {
      navBarTitle.textColor = self.titleColor
    }
    navBarTitle.shadowOffset = CGSize(width: 0, height: 1);
    navBarTitle.font = UIFont(name: "HelveticaNeue-Medium", size: 17.0)
    navBarTitle.textAlignment = .center
    navBarTitle.sizeToFit()
    
    navigationItem.titleView = navBarTitle;
    
    
    super.viewWillAppear(true)
    guard customRightItem == nil else { return }
    if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
      self.navigationController?.setToolbarHidden(false, animated: false)
    }
    else if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
      self.navigationController?.setToolbarHidden(true, animated: true)
    }
  }
  
  override public func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    
    guard customRightItem == nil else { return }
    if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone) {
      self.navigationController?.setToolbarHidden(true, animated: true)
    }
  }
  
  override public func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
  
  ////////////////////////////////////////////////
  // Toolbar
  
  func updateToolbarItems() {
    guard customRightItem == nil else {
      self.navigationItem.rightBarButtonItem = customRightItem
      return
    }
    
    backBarButtonItem.isEnabled = webView.canGoBack
    forwardBarButtonItem.isEnabled = webView.canGoForward
    
    let refreshStopBarButtonItem: UIBarButtonItem = webView.isLoading ? stopBarButtonItem : refreshBarButtonItem
    
    let fixedSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
    let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    
    if (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad) {
      
      let toolbarWidth: CGFloat = 250.0
      fixedSpace.width = 35.0
      
      let items: NSArray = sharingEnabled ? [fixedSpace, refreshStopBarButtonItem, fixedSpace, backBarButtonItem, fixedSpace, forwardBarButtonItem, fixedSpace, actionBarButtonItem] : [fixedSpace, refreshStopBarButtonItem, fixedSpace, backBarButtonItem, fixedSpace, forwardBarButtonItem]
      
      let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: toolbarWidth, height: 44.0))
      if !closing {
        toolbar.items = items as? [UIBarButtonItem]
        if presentingViewController == nil {
          toolbar.barTintColor = navigationController!.navigationBar.barTintColor
        }
        else {
          toolbar.barStyle = navigationController!.navigationBar.barStyle
        }
        toolbar.tintColor = navigationController!.navigationBar.tintColor
      }
      navigationItem.rightBarButtonItems = items.reverseObjectEnumerator().allObjects as? [UIBarButtonItem]
      
    }
    else {
      let items: NSArray = sharingEnabled ? [fixedSpace, backBarButtonItem, flexibleSpace, forwardBarButtonItem, flexibleSpace, refreshStopBarButtonItem, flexibleSpace, actionBarButtonItem, fixedSpace] : [fixedSpace, backBarButtonItem, flexibleSpace, forwardBarButtonItem, flexibleSpace, refreshStopBarButtonItem, fixedSpace]
      
      if let navigationController = navigationController, !closing {
        if presentingViewController == nil {
          navigationController.toolbar.barTintColor = navigationController.navigationBar.barTintColor
        }
        else {
          navigationController.toolbar.barStyle = navigationController.navigationBar.barStyle
        }
        navigationController.toolbar.tintColor = navigationController.navigationBar.tintColor
        toolbarItems = items as? [UIBarButtonItem]
      }
    }
  }
  
  
  ////////////////////////////////////////////////
  // Target Actions
  
  @objc func goBackTapped(_ sender: UIBarButtonItem) {
    webView.goBack()
  }
  
  @objc func goForwardTapped(_ sender: UIBarButtonItem) {
    webView.goForward()
  }
  
  @objc func reloadTapped(_ sender: UIBarButtonItem) {
    webView.reload()
  }
  
  @objc func stopTapped(_ sender: UIBarButtonItem) {
    webView.stopLoading()
    updateToolbarItems()
  }
  
  @objc func actionButtonTapped(_ sender: AnyObject) {
    if let url: URL = (sharingUrl != nil) ? URL(string: sharingUrl!) : ((webView.url != nil) ? webView.url : request.url) {
      let activities: NSArray = [SwiftWebVCActivitySafari(), SwiftWebVCActivityChrome()]
      
      if url.absoluteString.hasPrefix("file:///") {
        let dc: UIDocumentInteractionController = UIDocumentInteractionController(url: url)
        dc.presentOptionsMenu(from: view.bounds, in: view, animated: true)
      }
      else {
        
        var items: [Any] = [];
        
        if let titleTmp = navBarTitle.text {
          items.append(titleTmp)
        }
        
        if let icon = sharingUrlIcon {
          items.append(icon)
        }
        
        items.append(url)
        
        let activityController: UIActivityViewController = UIActivityViewController(activityItems: items, applicationActivities: activities as? [UIActivity])
        
        if floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
          let ctrl: UIPopoverPresentationController = activityController.popoverPresentationController!
          ctrl.sourceView = view
          ctrl.barButtonItem = sender as? UIBarButtonItem
        }
        
        present(activityController, animated: true, completion: nil)
      }
    }
  }
  
  ////////////////////////////////////////////////
  
  @objc public func doneButtonTapped() {
    closing = true
    if let currentStoredStatusColor = storedStatusColor {
      UINavigationBar.appearance().barStyle = currentStoredStatusColor
    }
    self.dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Class Methods
  
  /// Helper function to get image within SwiftWebVCResources bundle
  ///
  /// - parameter named: The name of the image in the SwiftWebVCResources bundle
  class func bundledImage(named: String) -> UIImage? {
    let image = UIImage(named: named)
    if image == nil {
      return UIImage(named: named, in: Bundle(for: SwiftWebVC.classForCoder()), compatibleWith: nil)
    } // Replace MyBasePodClass with yours
    return image
  }
}

extension SwiftWebVC: WKUIDelegate {
  
  // Add any desired WKUIDelegate methods here: https://developer.apple.com/reference/webkit/wkuidelegate
  
}

extension SwiftWebVC: WKNavigationDelegate {
  
  public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    self.delegate?.didStartLoading()
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
    updateToolbarItems()
  }
  
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    self.delegate?.didFinishLoading(success: true)
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
    
    webView.evaluateJavaScript("document.title", completionHandler: {(response, error) in
      if self.webTitle == nil {
        self.navBarTitle.text = response as! String?
        self.navBarTitle.sizeToFit()
      }
      self.updateToolbarItems()
    })
    
  }
  
  public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    self.delegate?.didFinishLoading(success: false)
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
    updateToolbarItems()
  }
  
  public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    
    let url = navigationAction.request.url
    
    let hostAddress = navigationAction.request.url?.host
    
    if (navigationAction.targetFrame == nil) {
      if UIApplication.shared.canOpenURL(url!) {
        UIApplication.shared.openURL(url!)
      }
    }
    
    // To connnect app store
    if hostAddress == "itunes.apple.com" {
      if UIApplication.shared.canOpenURL(navigationAction.request.url!) {
        UIApplication.shared.openURL(navigationAction.request.url!)
        decisionHandler(.cancel)
        return
      }
    }
    
    let url_elements = url!.absoluteString.components(separatedBy: ":")
    
    switch url_elements[0] {
    case "tel":
      openCustomApp(urlScheme: "telprompt://", additional_info: url_elements[1])
      decisionHandler(.cancel)
      
    case "sms":
      openCustomApp(urlScheme: "sms://", additional_info: url_elements[1])
      decisionHandler(.cancel)
      
    case "mailto":
      openCustomApp(urlScheme: "mailto://", additional_info: url_elements[1])
      decisionHandler(.cancel)
      
    default:
      //print("Default")
      break
    }
    
    decisionHandler(.allow)
    
  }
  
  func openCustomApp(urlScheme: String, additional_info:String){
    
    if let requestUrl: URL = URL(string:"\(urlScheme)"+"\(additional_info)") {
      let application:UIApplication = UIApplication.shared
      if application.canOpenURL(requestUrl) {
        application.openURL(requestUrl)
      }
    }
  }
}

