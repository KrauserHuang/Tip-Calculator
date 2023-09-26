//
//  TipInputView.swift
//  Tip-Calculator
//
//  Created by Tai Chin Huang on 2023/9/12.
//

import UIKit
import Combine
import CombineCocoa

final class TipInputView: UIView {
    
    private let headerView: HeaderView = {
        let view = HeaderView()
        view.configure(
            topText: "Choose",
            bottomText: "your tip")
        return view
    }()
    
    private lazy var tenPercentTipButton: UIButton = {
        let button = buildTipButton(tip: .tenPercent)
        button.tapPublisher
            .flatMap { _ in
                Just(Tip.tenPercent)
            }
            .assign(to: \.value, on: tipSubject)
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var fifteenPercentTipButton: UIButton = {
        let button = buildTipButton(tip: .fifteenPercent)
        button.tapPublisher
            .flatMap { _ in
                Just(Tip.fifteenPercent)
            }
            .assign(to: \.value, on: tipSubject)
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var twentyPercentTipButton: UIButton = {
        let button = buildTipButton(tip: .twentyPercent)
        button.tapPublisher
            .flatMap { _ in
                Just(Tip.twentyPercent)
            }
            .assign(to: \.value, on: tipSubject)
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var customTipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Custom tip", for: .normal)
        button.titleLabel?.font = ThemeFont.bold(ofSize: 20)
        button.backgroundColor = ThemeColor.primary
        button.tintColor = .white
        button.addCornerRadius(radius: 8.0)
        button.tapPublisher
            .sink { [weak self] _ in
                self?.handleCustomTipButton()
            }
            .store(in: &cancellables)
        return button
    }()
    
    private lazy var buttonHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            tenPercentTipButton,
            fifteenPercentTipButton,
            twentyPercentTipButton
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    private lazy var buttonVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            buttonHStackView,
            customTipButton
        ])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()
    
    private var tipSubject: CurrentValueSubject<Tip, Never> = .init(.none)
//    private var tipSubject: PassthroughSubject<Tip, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    public var valuePublisher: AnyPublisher<Tip, Never> {
        return tipSubject.eraseToAnyPublisher()
    }
    
    /*
     CurrentValueSubject跟PassthroughSubject主要的差異是
     CurrentValueSubject可以存預設值進去
     */
    
    init() { // will use auto layout, don't need to care about frames
        super.init(frame: .zero)
        setupUI()
        setupConstraint()
        observe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Could not create TipInputView")
    }
    
    public func reset() {
        tipSubject.send(.none)
    }
    
    private func setupUI() {
        [headerView, buttonVStackView].forEach(addSubview(_:))
    }
    
    private func setupConstraint() {
        buttonVStackView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(buttonVStackView.snp.leading).offset(-24)
            make.width.equalTo(68)
            make.centerY.equalTo(buttonHStackView.snp.centerY)
        }
    }
    
    private func handleCustomTipButton() {
        let alertController: UIAlertController = {
            let controller = UIAlertController(
                title: "Enter Custom Tip",
                message: nil,
                preferredStyle: .alert)
            controller.addTextField { textField in
                textField.placeholder = "Make it generous!"
                textField.keyboardType = .numberPad
                textField.autocorrectionType = .no
            }
            let cancelAction = UIAlertAction(
                title: "Cancel",
                style: .cancel)
            let okAction = UIAlertAction(
                title: "OK",
                style: .default) { [weak self] _ in
                    guard let text = controller.textFields?.first?.text,
                          let value = Int(text) else { return }
                    self?.tipSubject.send(.custom(value: value))
                }
            [okAction, cancelAction].forEach(controller.addAction(_:))
            return controller
        }()
        parentViewController?.present(alertController, animated: true)
    }
    
    private func observe() {
        tipSubject
            .sink { [unowned self] tip in
                resetView()
                switch tip {
                case .none:
                    break
                case .tenPercent:
                    tenPercentTipButton.backgroundColor = ThemeColor.secondary
                case .fifteenPercent:
                    fifteenPercentTipButton.backgroundColor = ThemeColor.secondary
                case .twentyPercent:
                    twentyPercentTipButton.backgroundColor = ThemeColor.secondary
                case .custom(let value):
                    customTipButton.backgroundColor = ThemeColor.secondary
                    let text = NSMutableAttributedString(
                        string: "$\(value)",
                        attributes: [.font: ThemeFont.bold(ofSize: 20)])
                    text.addAttributes([
                        .font: ThemeFont.bold(ofSize: 14)
                    ], range: NSMakeRange(0, 1))
                    customTipButton.setAttributedTitle(text, for: .normal)
                }
            }
            .store(in: &cancellables)
    }
    
    private func resetView() {
        [tenPercentTipButton,
         fifteenPercentTipButton,
         twentyPercentTipButton,
         customTipButton].forEach {
            $0.backgroundColor = ThemeColor.primary
        }
        let text = NSMutableAttributedString(
            string: "Custom tip",
            attributes: [.font: ThemeFont.bold(ofSize: 20)])
        customTipButton.setAttributedTitle(text, for: .normal)
    }
    
    private func buildTipButton(tip: Tip) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = ThemeColor.primary
        button.tintColor = .white // 因為用了NSMutableAttributedString所以不能用tintColor修改
        button.addCornerRadius(radius: 8.0)
        let text = NSMutableAttributedString(
            string: tip.stringValue,
            attributes: [
                .font: ThemeFont.bold(ofSize: 20),
                .foregroundColor: UIColor.white
            ])
        text.addAttributes([
            .font: ThemeFont.demibold(ofSize: 14)],
                           range: NSMakeRange(2, 1))
        button.setAttributedTitle(text, for: .normal)
        return button
    }
}
