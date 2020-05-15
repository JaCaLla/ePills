//
//  Medicine.swift
//  ePills
//
//  Created by Javier Calatrava on 12/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

class Medicine: Identifiable {

	var id: String = UUID().uuidString
	var name: String
	var unitsBox: Int
	var unitsDose: Int
	var intervalSecs: Int = 0
	var currentCycle: Cycle
	var pastCycles: [Cycle] = []

	var creation: Int = Int(Date().timeIntervalSince1970)

	init(name: String, unitsBox: Int, intervalSecs: Int, unitsDose: Int) {
		self.name = name
		self.unitsBox = unitsBox
		self.intervalSecs = intervalSecs
		self.unitsDose = unitsDose
		self.currentCycle = Cycle()
	}

	func getState(timeManager: TimeManagerPrococol = TimeManager()) -> CyclesState {
		guard let nextDose = self.currentCycle.nextDose else {
			return currentCycle.unitsConsumed >= unitsBox ? .finished : .notStarted
		}
		if currentCycle.unitsConsumed >= unitsBox {
			return .finished
		} else {
			if timeManager.timeIntervalSince1970() > nextDose {
				return .ongoingEllapsed
			} else {
				return timeManager.timeIntervalSince1970() > nextDose - Cycle.Constants.ongoingReadyOffset ? . ongoingReady: .ongoing
			}
		}
	}

	func takeDose(timeManager: TimeManagerPrococol = TimeManager()) {
		let state = getState()
		if (state == .notStarted ||
				state == .ongoingReady ||
				state == .ongoingEllapsed) {
			self.currentCycle.unitsConsumed += self.unitsDose
			guard currentCycle.unitsConsumed < unitsBox else {
				currentCycle.nextDose = nil
				return
			}
			self.currentCycle.nextDose = timeManager.timeIntervalSince1970() + self.intervalSecs
		}
	}

	func getNextDose() -> Int? {
		return currentCycle.nextDose
	}

	func isFirst() -> Bool {
		return currentCycle.unitsConsumed == 0
	}

	func isLast() -> Bool {
		return currentCycle.unitsConsumed + unitsDose >= unitsBox
	}
}


extension Medicine: Equatable {
	static func == (lhs: Medicine, rhs: Medicine) -> Bool {
		return lhs.name == rhs.name &&
			lhs.unitsBox == rhs.unitsBox &&
			lhs.intervalSecs == rhs.intervalSecs &&
			lhs.unitsDose == rhs.unitsDose //&&
			//lhs.currentCycle == rhs.currentCycle
	}
}
