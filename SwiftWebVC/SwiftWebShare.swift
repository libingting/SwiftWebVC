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
    addSubviews([lbTitle, btnWeChat, btnFriends, cancel])
    backgroundColor = MBColor(hex: 0xF5F5F6)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    lbTitle.pin.top(14).left().right().height(19)
    
    let btns: [MBButton] = [btnWeChat, btnFriends]
    let unitSpace = width / CGFloat(btns.count + 1)
    for (index, btn) in btns.enumerated() {
      btn.pin.below(of: lbTitle).marginTop(25).left(unitSpace + unitSpace * CGFloat(index) - 60)
    }

    cancel.pin.bottom().left().right().height(36.0 + safeBottom())
  }
  
  @discardableResult
  class func show(At: UIView) -> SwiftWebShareView {
    
    for view in At.subviews {
      if let web: SwiftWebShareView = view as? SwiftWebShareView {
        web.cancelAction()
        return web
      }
    }
    
    var bottomValue: CGFloat = 0.0
    if #available(iOS 11.0, *) {
      bottomValue = At.safeAreaInsets.bottom
    } else {
      // Fallback on earlier versions
    }
    let obj = SwiftWebShareView(frame: CGRectMake(0, 0, At.width, 183.0 + bottomValue))
    obj.y = At.height
    At.addSubviews([obj])
    UIView.animate(withDuration: 0.3) {
      obj.y = At.height - obj.height
    }
    return obj
  }
  
  @objc func cancelAction() {
    UIView.animate(withDuration: 0.3, animations: {
      self.y = self.superview!.height
    }) { (finish) in
      self.removeFromSuperview()
    }
  }
  
  @objc func tapAction(btn: MBButton) {
    if let value = delegate?.swiftWebShareViewAction(index: SwiftWebShareAction(rawValue: btn.tag)!), value {
      cancelAction()
    }
  }
  
  // MARK: - getter
  lazy var btnWeChat: MBButton = {
    let obj = MBButton(type: UIButtonType.custom)
    obj.image = SwiftWebVC.bundledImage(named: "SwiftWebVCWeixin")
    obj.title = "微信"
    obj.titleFont = UIFont.systemFont(ofSize: 11)
    obj.titleColor = UIColor.black
    obj.size = CGSizeMake(120, 70)
    obj.setImageAlignmentToTop(titleSpace: 4)
    obj.tag = SwiftWebShareAction.weChat.rawValue
    obj.addTarget(self, action: #selector(tapAction(btn:)))
    return obj
  }()
  
  lazy var btnFriends: MBButton = {
    let obj = MBButton(type: UIButtonType.custom)
    obj.image = SwiftWebVC.bundledImage(named: "SwiftWebVCFriend")
     obj.title = "微信朋友圈"
    obj.titleFont = UIFont.systemFont(ofSize: 11)
    obj.titleColor = UIColor.black
    obj.size = CGSizeMake(120, 70)
    obj.setImageAlignmentToTop(titleSpace: 4)
    obj.tag = SwiftWebShareAction.friends.rawValue
    obj.addTarget(self, action: #selector(tapAction(btn:)))
    return obj
  }()
  
  lazy var lbTitle: MBLabel = {
    let obj = MBLabel()
    obj.text = "分享到"
    obj.font = UIFont.systemFont(ofSize: 13)
    obj.textAlignment = .center
    return obj
  }()
  
  lazy var cancel: MBButton = {
    let obj = MBButton()
    obj.title = "取消分享"
    obj.titleFont = UIFont.systemFont(ofSize: 13)
    obj.backgroundColor = UIColor.white
    obj.addTarget(self, action: #selector(cancelAction))
    return obj
  }()
  
}
