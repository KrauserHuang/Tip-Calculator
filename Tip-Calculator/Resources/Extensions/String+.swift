//
//  String+.swift
//  Tip-Calculator
//
//  Created by Tai Chin Huang on 2023/9/21.
//

import Foundation

extension String {
    var doubleValue: Double? { // -> 能轉換就轉成Double，不能就回傳nil
        Double(self)
    }
}
