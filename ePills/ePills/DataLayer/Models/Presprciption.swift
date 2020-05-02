//
//  Presprciption.swift
//  ePills
//
//  Created by Javier Calatrava on 25/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

enum PrescriptionState {
    case notStarted
    case ongoing
    case finished
}

struct Prescription {
    let id = UUID()
    var name: String
    var unitsBox: Int
    var interval: Interval
    var unitsDose: Int
    var unitsConsumed: Int = 0
    var nextDose: Int?
    var creation: Int = Int(Date().timeIntervalSince1970)

    func getState() -> PrescriptionState {
        guard nextDose != nil else {
            return .notStarted
        }
        return unitsConsumed >= unitsBox ? .finished : .ongoing
    }

    mutating func takeDose() {
        guard getState() != .finished else { return }
        self.unitsConsumed += self.unitsDose
        if let uwpNextDose = self.nextDose {
            self.nextDose = uwpNextDose + self.interval.hours * 3600
        } else {
            self.nextDose = Int(Date().timeIntervalSince1970) + self.interval.hours * 3600
        }
    }
    
    func title() -> String {
        return "\(self.name) [\(self.unitsConsumed)/\(self.unitsBox)]"
    }
}

extension Prescription: Equatable {
    static func == (lhs: Prescription, rhs: Prescription) -> Bool {
        return lhs.name == rhs.name &&
            lhs.unitsBox == rhs.unitsBox &&
            lhs.interval == rhs.interval &&
            lhs.unitsDose == rhs.unitsDose
    }
}
