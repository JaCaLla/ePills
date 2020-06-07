//
//  DoseListViewModel.swift
//  ePills
//
//  Created by Javier Calatrava on 02/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

enum DoseCellType {
    case monoCycle
    case startPast
    case middle
    case endPast
    case endToday
}

struct DoseCellViewModel: Identifiable {

    public let id = UUID()
    var doseOrder: String
    var day:String
    var monthYear:String
    var weekdayHHMM: String
    var realOffset: String
    var realOffsetColorStr: String = R.color.colorBlack.name
    var doseCellType: DoseCellType
}
