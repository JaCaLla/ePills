//
//  DateExtension.swift
//  ePills
//
//  Created by Javier Calatrava on 10/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

extension Date {
    // This method cannot be consolidated into the Date extension, because
    // it cannot be compiled into VLGNextFlightWidget target
    func format(_ format: String) -> String {
        /// return VLVuelingUtils.string(from: self, format: format)

        let dateformat = DateFormatter()
        dateformat.timeZone = TimeZone(abbreviation: "UTC")
        dateformat.locale = Locale(identifier: "en_US_POSIX")
        dateformat.calendar = Calendar(identifier: .gregorian)
        dateformat.dateFormat = format
        return dateformat.string(from: self)

    }
}
