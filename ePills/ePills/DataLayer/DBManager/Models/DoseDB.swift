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
     @objc dynamic var expected: Int = -1
      @objc dynamic var real: Int = -1
    
    // MARK: - Initializers
    convenience init(id: String,
                     expected: Int,
                     real: Int) {

        self.init()
        self.id = id
        self.expected = expected
        self.real = real
    }
    
    convenience init(dose: Dose) {
        self.init(id: dose.id,
                  expected: dose.expected,
                  real: dose.real)
    }
    
    func getDose(timeManager: TimeManagerPrococol = TimeManager()) -> Dose {
        let dose = Dose(expected: self.expected,
                                        timeManager: timeManager)
        dose.id = id
        dose.expected = expected
        dose.real = real
        return dose
    }
}
