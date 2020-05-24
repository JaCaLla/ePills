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
	@objc dynamic var update: Int = Int(Date().timeIntervalSince1970)
	@objc dynamic var creation: Int = Int(Date().timeIntervalSince1970)

	convenience init(name: String, unitsBox: Int, interval: Int, unitsDose: Int) {
		self.init()
		self.id = UUID().uuidString
		self.name = name
		self.unitsBox = unitsBox
		self.interval = interval
		self.unitsDose = unitsDose
	}

	convenience init(medicine: Medicine) {
		self.init(name: medicine.name,
			unitsBox: medicine.unitsBox,
			interval: medicine.intervalSecs,
			unitsDose: medicine.unitsDose)
	}

	func getMedicine() -> Medicine {
		let medicine = Medicine(name: name, unitsBox: unitsBox, intervalSecs: interval, unitsDose: unitsDose)
		medicine.id = id
		return medicine
	}
}
