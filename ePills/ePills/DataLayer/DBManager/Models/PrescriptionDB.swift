//
//  IssueDB.swift
//  secoTests
//
//  Created by Javier Calatrava on 28/02/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import RealmSwift

class PrescriptionDB: Object {

    @objc dynamic var id: String = ""
     @objc dynamic var name: String = ""
     @objc dynamic var unitsBox: Int = -1
     @objc dynamic var interval: Int = -1
     @objc dynamic var unitsDose: Int = -1
     @objc dynamic var unitsConsumed: Int = -1
     @objc dynamic var nextDose: Int = -1
     @objc dynamic var creation: Int = -1

    // MARK: - Initializers
    convenience init(id: String,
                     name: String,
                     unitsBox: Int,
                     interval: Int,
                     unitsDose: Int,
                     unitsConsumed: Int,
                     nextDose: Int,
                     creation: Int) {

        self.init()
        self.id = id
        self.name = name
        self.unitsBox = unitsBox
        self.interval = interval
        self.unitsDose = unitsDose
        self.unitsConsumed = unitsConsumed
        self.nextDose = nextDose
        self.creation = creation
    }

//    convenience init(prescription: Cycle) {
//        self.init(id: prescription.id,
//                  name: prescription.name,
//                  unitsBox: prescription.unitsBox,
//                  interval: prescription.intervalSecs,
//                  unitsDose: prescription.unitsDose,
//                  unitsConsumed: prescription.unitsConsumed,
//                  nextDose: prescription.nextDose ?? -1,
//                  creation: prescription.creation)
//    }
//    
//    func getPrescription() -> Cycle {
//        let prescription = Cycle(name: self.name,
//                                        unitsBox: self.unitsBox,
//                                        intervalSecs: self.interval,
//                                        unitsDose: self.unitsDose)
//        prescription.id = id
//        prescription.unitsConsumed = unitsConsumed
//        prescription.nextDose = nextDose >= 0 ? nextDose : nil
//        prescription.creation = creation
//        return prescription
//    }

    // MARK: - Realm
    override class func primaryKey() -> String? {
        return "id"
    }

    override class func indexedProperties() -> [String] {
        return []
    }

    override static func ignoredProperties() -> [String] {
        return []
    }
}
