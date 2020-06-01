//
//  CycleDB.swift
//  ePills
//
//  Created by Javier Calatrava on 14/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import RealmSwift

class CycleDB: Object {

	@objc dynamic var id: String = ""
	@objc dynamic var medicineId: String = ""
	@objc dynamic var unitsConsumed: Int = -1
	@objc dynamic var nextDose: Int = -1
	@objc dynamic var creation: Int = -1
    @objc dynamic var update: Int = -1
	// @objc dynamic var doses: [Dose]

    convenience init(medicineId: String, unitsConsumed: Int, nextDose: Int, timeManager: TimeManagerProtocol = TimeManager()) {
		self.init()
		self.id = UUID().uuidString
		self.medicineId = medicineId
		self.unitsConsumed = unitsConsumed
		self.nextDose = nextDose
        self.creation = timeManager.timeIntervalSince1970()
         self.update = timeManager.timeIntervalSince1970()
	}

	convenience init(cycle: Cycle, medicineId: String, timeManager: TimeManagerProtocol = TimeManager()) {
		self.init(medicineId: medicineId,
			unitsConsumed: cycle.unitsConsumed,
			nextDose: cycle.nextDose ?? -1,
            timeManager: timeManager)
	}

	func getCycle() -> Cycle {
		let cycle = Cycle(unitsConsumed: self.unitsConsumed, nextDose: self.nextDose == -1 ? nil : self.nextDose)
		cycle.id = id
		cycle.medicineId = self.medicineId
        cycle.update = self.update
        cycle.creation = self.creation
		return cycle
	}
}
