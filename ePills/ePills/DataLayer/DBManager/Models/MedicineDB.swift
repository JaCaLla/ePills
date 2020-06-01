//
//  MedicineDB.swift
//  ePills
//
//  Created by Javier Calatrava on 14/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import RealmSwift

class MedicineDB: Object {

	@objc dynamic var id: String = ""
	@objc dynamic var name: String = ""
	@objc dynamic var unitsBox: Int = -1
	@objc dynamic var interval: Int = -1
	@objc dynamic var unitsDose: Int = -1
	@objc dynamic var update: Int = -1
	@objc dynamic var creation: Int = -1

	convenience init(name: String, unitsBox: Int, interval: Int, unitsDose: Int, timeManager: TimeManagerProtocol = TimeManager()) {
		self.init()
		self.id = UUID().uuidString
		self.name = name
		self.unitsBox = unitsBox
		self.interval = interval
		self.unitsDose = unitsDose
        self.creation = timeManager.timeIntervalSince1970()
         self.update = timeManager.timeIntervalSince1970()
	}

	convenience init(medicine: Medicine, timeManager: TimeManagerProtocol = TimeManager()) {
		self.init(name: medicine.name,
			unitsBox: medicine.unitsBox,
			interval: medicine.intervalSecs,
            unitsDose: medicine.unitsDose,
            timeManager: timeManager)
	}

	func getMedicine() -> Medicine {
		let medicine = Medicine(name: name, unitsBox: unitsBox, intervalSecs: interval, unitsDose: unitsDose)
		medicine.id = id
        medicine.creation = creation
		return medicine
	}
}
