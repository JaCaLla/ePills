//
//  Dose.swift
//  ePills
//
//  Created by Javier Calatrava on 11/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

public final class Dose: Identifiable {

	public var id: String = ""
	var cycleId: String = ""
	var expected: Int
	var real: Int

	init(expected: Int, timeManager: TimeManagerProtocol = TimeManager()) {
		self.expected = expected
		self.real = timeManager.timeIntervalSince1970()
	}

}
