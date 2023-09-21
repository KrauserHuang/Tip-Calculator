//
//  CalculatorVM.swift
//  Tip-Calculator
//
//  Created by Tai Chin Huang on 2023/9/21.
//

import Foundation
import Combine

class CalculatorVM {
    
    struct Input {
        let billPublisher: AnyPublisher<Double, Never>
        let tipPublisher: AnyPublisher<Tip, Never>
        let splitPublisher: AnyPublisher<Int, Never>
    }
    
    struct Output {
        let updateViewPublisher: AnyPublisher<Result, Never>
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func transform(input: Input) -> Output {
        
        input.billPublisher
            .sink { bill in
                print("the bill: \(bill)")
            }
            .store(in: &cancellables)
        
        let result = Result(
            amountPerPerson: 500,
            totalBill: 1000,
            totalTip: 50.0)
        return Output(updateViewPublisher: Just(result).eraseToAnyPublisher())
    }
}
