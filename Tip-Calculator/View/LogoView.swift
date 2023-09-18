//
//  LogoView.swift
//  Tip-Calculator
//
//  Created by Tai Chin Huang on 2023/9/12.
//

import UIKit

final class LogoView: UIView {
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
    
    init() { // will use autolayout, don't need to care about frames
        super.init(frame: .zero)
        setupUI()
        setupConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Could not create LogoView")
    }
    
    private func setupUI() {
        backgroundColor = .red
    }
    
    private func setupConstraint() {
        
    }
}
