//
//  UIResponder+.swift
//  Tip-Calculator
//
//  Created by Tai Chin Huang on 2023/9/21.
//

import UIKit

extension UIResponder {
    var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
