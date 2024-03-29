//
//  SplitInputView.swift
//  Tip-Calculator
//
//  Created by Tai Chin Huang on 2023/9/12.
//

import UIKit
import Combine
import CombineCocoa

final class SplitInputView: UIView {
    
    private let headerView: HeaderView = {
        let view = HeaderView()
        view.configure(
            topText: "Split",
            bottomText: "the total")
        return view
    }()
    
    private lazy var decrementButton: UIButton = {
        let button = buildButton(
            text: "-",
            corners: [.layerMinXMaxYCorner, .layerMinXMinYCorner])
        button.tapPublisher
            .flatMap { [unowned self] _ in
                Just(splitSubject.value == 1 ? 1 : splitSubject.value - 1)
        }
            .assign(to: \.value, on: splitSubject)
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var incrementButton: UIButton = {
        let button = buildButton(
            text: "+",
            corners: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
        button.tapPublisher
            .flatMap { [unowned self] _ in
            Just(splitSubject.value + 1)
        }
            .assign(to: \.value, on: splitSubject)
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = LabelFactory.build(
            text: "1",
            font: ThemeFont.bold(ofSize: 20),
            backgroundColor: .white)
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            decrementButton,
            quantityLabel,
            incrementButton
        ])
        stackView.axis = .horizontal
        stackView.spacing = 0
        return stackView
    }()
    
    private let splitSubject: CurrentValueSubject<Int, Never> = .init(1)
    private var cancellables = Set<AnyCancellable>()
    
    public var valuePublisher: AnyPublisher<Int, Never> {
        return splitSubject.removeDuplicates().eraseToAnyPublisher()
    }
    
    init() { // will use auto layout, don't need to care about frames
        super.init(frame: .zero)
        setupUI()
        setupConstraint()
        observe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Could not create SplitInputView")
    }
    
    public func reset() {
        splitSubject.send(1)
    }
    
    private func setupUI() {
        [headerView, stackView].forEach(addSubview(_:))
    }
    
    private func setupConstraint() {
        stackView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
        }
        
        [incrementButton, decrementButton].forEach { button in
            button.snp.makeConstraints { make in
                make.width.equalTo(button.snp.height)
            }
        }
        
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalTo(stackView.snp.centerY)
            make.trailing.equalTo(stackView.snp.leading).offset(-24)
            make.width.equalTo(68)
        }
    }
    
    private func observe() {
        splitSubject
            .sink { [unowned self] quantity in
                quantityLabel.text = quantity.stringValue
            }
            .store(in: &cancellables)
    }
    
    private func buildButton(text: String, corners: CACornerMask) -> UIButton {
        let button = UIButton()
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = ThemeFont.bold(ofSize: 20)
        button.addRoundedCorner(corners: corners, radius: 8.0)
        button.backgroundColor = ThemeColor.primary
        return button
    }
}
