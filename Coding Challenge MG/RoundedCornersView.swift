//
//  RoundedCornersView.swift
//  Coding Challenge MG
//
//  Created by Michael Gasparik on 19/06/16.
//  Copyright © 2016 Michael Gasparik. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedCornersView: UIView {
  @IBInspectable var cornerRadius: CGFloat = 0 {
    didSet {
      layer.cornerRadius = cornerRadius
      layer.masksToBounds = cornerRadius > 0
    }
  }
}
