//
//  Presprciption.swift
//  ePills
//
//  Created by Javier Calatrava on 25/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

struct Prescription {
    var name: String
    var unitsBox: String
    var selectedIntervalIndex: Interval
    var unitsDose: String
}

extension Prescription: Equatable {
    static func == (lhs: Prescription, rhs: Prescription) -> Bool {
        return lhs.name == rhs.name &&
        lhs.unitsBox == rhs.unitsBox &&
        lhs.selectedIntervalIndex == rhs.selectedIntervalIndex &&
        lhs.unitsDose == rhs.unitsDose
    }
}
