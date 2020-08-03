//
//  Medicine.swift
//  ePills
//
//  Created by Javier Calatrava on 12/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

class Medicine: Identifiable {

	var id: String = ""
	var name: String
	var unitsBox: Int
	var unitsDose: Int
	var intervalSecs: Int = 0
    var pictureFilename: String?
	var currentCycle: Cycle
	var pastCycles: [Cycle] = []

	var creation: Int = -1

	init(name: String, unitsBox: Int, intervalSecs: Int, unitsDose: Int, medicinePictureFilename: String? = nil) {
		self.name = name
		self.unitsBox = unitsBox
		self.intervalSecs = intervalSecs
		self.unitsDose = unitsDose
		self.currentCycle = Cycle(unitsConsumed: 0, nextDose: nil)
        self.pictureFilename = medicinePictureFilename
	}

	func getState(timeManager: TimeManagerProtocol = TimeManager()) -> CyclesState {
		guard let nextDose = self.currentCycle.nextDose else {
			return currentCycle.unitsConsumed >= unitsBox ? .finished : .notStarted
		}
		if currentCycle.unitsConsumed >= unitsBox {
			return .finished
		} else {
			if timeManager.timeIntervalSince1970() > nextDose {
				return .ongoingEllapsed
			} else {
                let currentTime = timeManager.timeIntervalSince1970()
				return currentTime > nextDose - Cycle.Constants.ongoingReadyOffset ? . ongoingReady: .ongoing
			}
		}
	}

	func takeDose(timeManager: TimeManagerProtocol = TimeManager()) {
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
			lhs.unitsDose == rhs.unitsDose 
	}
}
