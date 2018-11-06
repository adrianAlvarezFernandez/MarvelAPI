//
//  UIView+Additions.swift
//  MarvelAPI
//
//  Created by adrian.a.fernandez on 12/10/2018.
//  Copyright © 2018 adrian.a.fernandez. All rights reserved.
//

import UIKit

extension UIView {
    func anchor(left: NSLayoutXAxisAnchor? = nil, top: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, width: CGFloat? = nil, height: CGFloat? = nil, edgesInsets: UIEdgeInsets? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: edgesInsets?.left ?? 0).isActive = true
        }
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: edgesInsets?.top ?? 0).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -(edgesInsets?.right ?? 0)).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -(edgesInsets?.bottom ?? 0)).isActive = true
        }
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if left == nil && right == nil, let superview = superview {
            centerXAnchor.constraint(equalTo: superview.centerXAnchor, constant: 0).isActive = true
        }
    }
}
