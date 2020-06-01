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
    case ongoingReady
    case ongoingEllapsed
    case finished
}

class Prescription: Identifiable {

    struct Constants {
        static let ongoingReadyOffset: Int = 5
    }

    let id: UUID = UUID()
    var name: String
    var unitsBox: Int
    var interval: Interval
    var unitsDose: Int
    var unitsConsumed: Int = 0
    var nextDose: Int?
    var creation: Int = Int(Date().timeIntervalSince1970)

    init(name: String, unitsBox: Int, interval: Interval, unitsDose: Int) {
        self.name = name
        self.unitsBox = unitsBox
        self.interval = interval
        self.unitsDose = unitsDose
    }

    func getState(timeManager: TimeManagerProtocol = TimeManager()) -> PrescriptionState {
        guard let nextDose = self.nextDose else {
            return unitsConsumed >= unitsBox ? .finished : .notStarted
        }
        if unitsConsumed >= unitsBox {
            return .finished
        } else {
            if timeManager.timeIntervalSince1970() > nextDose {
                return .ongoingEllapsed
            } else {
                return timeManager.timeIntervalSince1970() > nextDose - Prescription.Constants.ongoingReadyOffset ? . ongoingReady: .ongoing
            }
        }
    }

    func takeDose(timeManager: TimeManagerProtocol = TimeManager()) {
        let state = getState()
        if (state == .notStarted ||
                state == .ongoingReady ||
                state == .ongoingEllapsed) {
            self.unitsConsumed += self.unitsDose
            guard unitsConsumed < unitsBox else {
                nextDose = nil
                return
            }
            self.nextDose = timeManager.timeIntervalSince1970() + self.interval.secs
        }
    }

    func isFirst() -> Bool {
        return unitsConsumed == 0
    }
    
    func isLast() -> Bool {
        return unitsConsumed + unitsDose >= unitsBox
    }
    
    func getRemaining(timeManager: TimeManagerProtocol = TimeManager()) -> Int? {

        guard let nextDose = self.nextDose else { return nil }
        return Int(timeManager.timeIntervalSince1970()) - nextDose
    }

    func getRemainingMins(timeManager: TimeManagerProtocol = TimeManager()) -> Int? {
        guard let remainigSecs = getRemaining(timeManager: timeManager) else { return nil }
        return Int(floor(Double(remainigSecs / 60)))
    }

    func getRemainingHours(timeManager: TimeManagerProtocol = TimeManager()) -> Int? {
        guard let remainigMins = getRemainingMins(timeManager: timeManager) else { return nil }
        return Int(floor(Double(remainigMins / 60)))
    }

    func getRemainingDays(timeManager: TimeManagerProtocol = TimeManager()) -> Int? {
        guard let remainigHours = getRemainingHours(timeManager: timeManager) else { return nil }
        return Int(floor(Double(remainigHours / 24)))
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
