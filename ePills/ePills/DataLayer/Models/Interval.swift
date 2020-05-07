//
//  Interval.swift
//  ePills
//
//  Created by Javier Calatrava on 25/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

struct Interval: Identifiable, CustomStringConvertible, Equatable {
    var description: String {
        label
    }

    let id: UUID = UUID()
    var secs: Int
    var label: String

    static func == (lhs: Interval, rhs: Interval) -> Bool {
        return lhs.secs == rhs.secs &&
        lhs.label == rhs.label 
    }
}
