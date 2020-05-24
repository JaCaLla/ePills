//
//  IntervalDB.swift
//  ePills
//
//  Created by Javier Calatrava on 11/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import RealmSwift

class DoseDB: Object {
	@objc dynamic var id: String = ""
	@objc dynamic var cycleId: String = ""
	@objc dynamic var expected: Int = -1
	@objc dynamic var real: Int = -1

	// MARK: - Initializers
	convenience init(cycleId: String,
		expected: Int,
		real: Int) {

		self.init()
		self.id = UUID().uuidString
		self.cycleId = cycleId
		self.expected = expected
		self.real = real
	}

	convenience init(dose: Dose, cycleId: String) {
		self.init(cycleId: cycleId,
			expected: dose.expected,
			real: dose.real)
	}

	func getDose() -> Dose {
		let dose = Dose(expected: self.expected)
		dose.id = id
		dose.cycleId = cycleId
		dose.real = real
		return dose
	}
}
