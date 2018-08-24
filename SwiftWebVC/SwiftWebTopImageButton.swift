//
//  WMTopImageButton.swift
//  weimai
//
//  Created by libingting on 2018/8/21.
//  Copyright © 2018年 侯耀东. All rights reserved.
//

import MBUIKit
import MBCoreKit
import MBNetKit

class SwiftWebTopImageButton: UIButton {
  
  /// 文字间距
  var titleSpace: CGFloat = 4
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    
    self.setup()
  }
  
  public init() {
    super.init(frame: .zero)
    self.setup()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    self.setup()
  }
  
  func setup() {
    addSubviews([ivIcon, lbTitle])
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    ivIcon.sizeToFit()
    lbTitle.sizeToFit()
    
    let maxImageHeight = height - lbTitle.height - titleSpace
    
    if ivIcon.height > maxImageHeight {
      let sc = ivIcon.height / maxImageHeight
      ivIcon.size = CGSizeMake(ivIcon.width / sc, ivIcon.height / sc)
    }
    
    let maxHeight = lbTitle.height + titleSpace + ivIcon.height

    ivIcon.pin.top((height - maxHeight)/2.0).hCenter()
    lbTitle.pin.below(of: ivIcon).marginTop(titleSpace).hCenter()
    
  }
  
  override func setTitle(_ title: String?, for state: UIControlState) {
    lbTitle.text = title
  }
  
  override func setImage(_ image: UIImage?, for state: UIControlState) {
    ivIcon.image = image
  }
  
  func addTarget(_ target: Any?, action: Selector) {
    addTarget(target, action: action, for: UIControlEvents.touchUpInside)
  }
  
  func config(title: String, titleColor: MBColor? = nil, bgColor: MBColor? = nil, font: MBFont? = nil) {
    lbTitle.text = title
    lbTitle.textColor = titleColor
    backgroundColor = bgColor
    lbTitle.font = font
  }
  
  /// mark
  lazy var ivIcon: MBImageView = {
    let obj = MBImageView()
    return obj
  }()
  
  lazy var lbTitle: MBLabel = {
    let obj = MBLabel()
    return obj
  }()
  
}
