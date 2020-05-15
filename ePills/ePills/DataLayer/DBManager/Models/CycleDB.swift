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
    @objc dynamic var unitsConsumed: Int = -1
    @objc dynamic var nextDose: Int = -1
    @objc dynamic var creation: Int = -1
   // @objc dynamic var doses: [Dose]
    
    convenience init(id: String, unitsConsumed: Int, nextDose: Int, creation: Int) {
        self.init()
        self.id = id
        self.unitsConsumed = unitsConsumed
        self.nextDose = nextDose
        self.creation = creation
    }
    
    convenience init(cycle: Cycle) {
        self.init(id: cycle.id,
        unitsConsumed: cycle.unitsConsumed,
        nextDose: cycle.nextDose ?? -1,
        creation: cycle.creation)
    }
    
}
