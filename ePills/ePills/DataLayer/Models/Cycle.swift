//
//  Cycle.swift
//  ePills
//
//  Created by Javier Calatrava on 15/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

enum CyclesState {
    case notStarted
    case ongoing
    case ongoingReady
    case ongoingEllapsed
    case finished
}

class Cycle: Identifiable {

    struct Constants {
        static let ongoingReadyOffset: Int = 5
    }

    var id: String = UUID().uuidString
    var unitsConsumed: Int = 0
    var nextDose: Int?
    var creation: Int = Int(Date().timeIntervalSince1970)
    
    init() {

    }

    func getRemaining(timeManager: TimeManagerPrococol = TimeManager()) -> Int? {

        guard let nextDose = self.nextDose else { return nil }
        return Int(timeManager.timeIntervalSince1970()) - nextDose
    }

    func getRemainingMins(timeManager: TimeManagerPrococol = TimeManager()) -> Int? {
        guard let remainigSecs = getRemaining(timeManager: timeManager) else { return nil }
        return Int(floor(Double(remainigSecs / 60)))
    }

    func getRemainingHours(timeManager: TimeManagerPrococol = TimeManager()) -> Int? {
        guard let remainigMins = getRemainingMins(timeManager: timeManager) else { return nil }
        return Int(floor(Double(remainigMins / 60)))
    }

    func getRemainingDays(timeManager: TimeManagerPrococol = TimeManager()) -> Int? {
        guard let remainigHours = getRemainingHours(timeManager: timeManager) else { return nil }
        return Int(floor(Double(remainigHours / 24)))
    }

}

extension Cycle: Equatable {
    static func == (lhs: Cycle, rhs: Cycle) -> Bool {
        guard let lhsNextDose = lhs.nextDose,
            let rhsNextDose = rhs.nextDose,
            lhsNextDose == rhsNextDose else {
            return false
        }
        
        return lhs.unitsConsumed == rhs.unitsConsumed &&
            lhs.nextDose == rhs.nextDose
    }
}

  
