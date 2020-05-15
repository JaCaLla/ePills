//
//  MedicineDB.swift
//  ePills
//
//  Created by Javier Calatrava on 14/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Swift

public final class MedicineDB  {
    
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var unitsBox: Int = -1
    @objc dynamic var interval: Int = -1
    @objc dynamic var unitsDose: Int = -1
    @objc dynamic var unitsConsumed: Int = -1
    @objc dynamic var nextDose: Int = -1
    @objc dynamic var creation: Int = -1
}
