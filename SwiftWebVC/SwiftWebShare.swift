//
//  SwiftWebShare.swift
//  SwiftWebVC
//
//  Created by libingting on 2018/8/20.
//

import MBCoreKit
import MBUIKit
import PinLayout

/// 分享操作
public enum SwiftWebShareAction: Int {
  /// 微信
  case weChat = 10
  /// 朋友圈
  case friends = 11
}

protocol SwiftWebShareViewDelegate: NSObjectProtocol {
  func swiftWebShareViewAction(index: SwiftWebShareAction) -> Bool
}

class SwiftWebShareView: MBView {
  
  weak var delegate: SwiftWebShareViewDelegate?
  
  override func setup() {
    super.setup()
    addSubviews([bgView ,lbTitle, btnWeChat, btnFriends, cancel])
    backgroundColor = MBColor.clear
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    bgView.pin.all()
    
    lbTitle.pin.top(16).left().right().height(17)
    
    let btns: [SwiftWebTopImageButton] = [btnWeChat, btnFriends]
    let unitSpace: CGFloat = 70.0
    for (index, btn) in btns.enumerated() {
      btn.pin.below(of: lbTitle).marginTop(18.0).left(15.0 + unitSpace * CGFloat(index))
    }

    cancel.pin.bottom().left().right().height(44.0 + safeBottom())
  }
  
  @discardableResult
  class func show() -> SwiftWebShareView? {
    guard let window = UIApplication.shared.keyWindow else { return nil }
    
    for view in window.subviews {
      if let web: SwiftWebShareView = view as? SwiftWebShareView {
        web.cancelAction()
        return web
      }
    }
    
    var bottomValue: CGFloat = 0.0
    if #available(iOS 11.0, *) {
      bottomValue = window.safeAreaInsets.bottom
    } else {
      // Fallback on earlier versions
    }
    let obj = SwiftWebShareView(frame: CGRectMake(0, 0, window.width, 191.0 + bottomValue))
    obj.y = window.height
    
    let bgView = MBView(frame: window.bounds)
    bgView.backgroundColor = MBColor(hex: 0x000000, transparency: 0.2)
    let touchView = MBView(frame: window.bounds)
    bgView.addSubview(touchView)
    bgView.addSubview(obj)
    let tapGes = UITapGestureRecognizer(target: obj, action: #selector(cancelAction))
    touchView.addGestureRecognizer(tapGes)
    
    window.addSubviews([bgView])
    UIView.animate(withDuration: 0.3) {
      obj.y = window.height - obj.height
    }
    return obj
  }
  
  @objc func cancelAction() {
    UIView.animate(withDuration: 0.3, animations: {
      self.y = self.superview!.height
    }) { (finish) in
      self.superview?.removeFromSuperview()
    }
  }
  
  @objc func tapAction(btn: MBButton) {
    if let value = delegate?.swiftWebShareViewAction(index: SwiftWebShareAction(rawValue: btn.tag)!), value {
      cancelAction()
    }
  }
  
  // MARK: - getter
  lazy var btnWeChat: SwiftWebTopImageButton = {
    let obj = SwiftWebTopImageButton(type: UIButtonType.custom)
    obj.image = SwiftWebVC.bundledImage(named: "SwiftWebVCWeixin")
    obj.title = "微信"
    obj.lbTitle.font = UIFont.systemFont(ofSize: 11)
    obj.lbTitle.textColor = MBColor(hex: 0x757475)
    obj.titleSpace = 7
    obj.size = CGSizeMake(60, 77)
    obj.tag = SwiftWebShareAction.weChat.rawValue
    obj.addTarget(self, action: #selector(tapAction(btn:)))
    return obj
  }()
  
  lazy var btnFriends: SwiftWebTopImageButton = {
    let obj = SwiftWebTopImageButton(type: UIButtonType.custom)
    obj.image = SwiftWebVC.bundledImage(named: "SwiftWebVCFriend")
    obj.title = "微信朋友圈"
    obj.lbTitle.font = UIFont.systemFont(ofSize: 11)
    obj.lbTitle.textColor = MBColor(hex: 0x757475)
    obj.titleSpace = 7
    obj.size = CGSizeMake(60, 77)
    obj.tag = SwiftWebShareAction.friends.rawValue
    obj.addTarget(self, action: #selector(tapAction(btn:)))
    return obj
  }()
  
  lazy var lbTitle: MBLabel = {
    let obj = MBLabel()
    obj.text = "分享到"
    obj.font = UIFont.systemFont(ofSize: 12)
    obj.textColor = MBColor(hex: 0x757475)
    obj.textAlignment = .center
    return obj
  }()
  
  lazy var cancel: MBButton = {
    let obj = MBButton()
    obj.title = "取消分享"
    obj.titleFont = UIFont.systemFont(ofSize: 13)
    obj.titleColor = MBColor(hex: 0x353535)
    obj.backgroundColor = MBColor(hex: 0xF4F4F6)
    obj.addTarget(self, action: #selector(cancelAction))
    return obj
  }()
  
  lazy var bgView: UIVisualEffectView = {
    let eff = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
    let obj = UIVisualEffectView(effect: eff)
    return obj
  }()
  
}
